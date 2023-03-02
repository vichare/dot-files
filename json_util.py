"""
Utilities functions and classes.
"""


def _key_repr(key: str):
    return "." + key if key.isidentifier() else f'["{key}"]'


# Parameter model is a data structure of types to define our expectation of a value.
# A valid model is one of following:
# * a type
# * a tuple containing one or more types meaning the value to be any one type in the tuple;
# * a List that contains one element that is a valid model;
# * a Dict that keys are either with type str or a tuple that conatins only one str or str itself,
#   and all values are valid models:
#   - a key with type str means the actual value must have the same key
#   - a one-string tuple indicates the string key is optional
#   - the type str itself as the key matches all those keys in actual value not covered by the
#     previous two cases
#   - if the model doesn't have str as key, no other keys are expected.
#
# Please refer to `test_util.py` in unit test for examples.
#
# Throws ValueError is the input value doesn't compliant with the model.
def validate_json(value, model, stack_trace="root") -> None:
    if isinstance(model, type):
        # We don't use isinstance(value, model) because isinstance(False, int) is true
        if type(value) != model:
            raise ValueError(
                f'Error on {stack_trace}: expect type "{model}", got type "{type(value)}".'
            )
    elif isinstance(model, tuple):
        # it must be a tuple of types.
        for sub_model in model:
            assert isinstance(sub_model, type), "model as tuple must only contain types"
        if type(value) not in model:
            raise ValueError(
                f'Error on {stack_trace}: expect type in "{list(model)}", got type "{type(value)}".'
            )
    elif isinstance(model, list):
        assert len(model) == 1, "model as a list should only contain one element"
        if not isinstance(value, list):
            raise ValueError(
                f'Error on {stack_trace}: expect type "list", got type "{type(value)}".'
            )
        for i in range(len(value)):
            validate_json(value[i], model[0], stack_trace + f"[{i}]")
    elif isinstance(model, dict):
        for k in model.keys():
            assert (
                isinstance(k, str)
                or k == str
                or (isinstance(k, tuple) and len(k) == 1 and isinstance(k[0], str))
            )
        if not isinstance(value, dict):
            raise ValueError(
                f'Error on {stack_trace}: expect type "dict", got type "{type(value)}".'
            )
        required_keys = set([k for k in model.keys() if isinstance(k, str)])
        optional_keys = set(
            [
                k[0]
                for k in model.keys()
                if isinstance(k, tuple) and len(k) == 1 and isinstance(k[0], str)
            ]
        )
        actual_keys = set(value.keys())
        missing_keys = required_keys - actual_keys
        extra_keys = actual_keys - required_keys - optional_keys
        if len(missing_keys) > 0:
            raise ValueError(f"Error on {stack_trace}: missing keys {missing_keys}")
        if len(extra_keys) > 0 and str not in model:
            raise ValueError(f"Error on {stack_trace}: unexpected keys {extra_keys}")
        for k, v in value.items():
            if k in required_keys:
                model_index = k
            elif k in optional_keys:
                model_index = (k,)
            else:
                # k in extra_keys
                model_index = str

            validate_json(v, model[model_index], stack_trace + _key_repr(k))


def assert_json_eq(expected, actual, stack_trace="root"):
    assert type(expected) == type(actual), (
        f"{stack_trace} type mismatch:" f"expect {type(expected)}, get {type(actual)}"
    )
    if isinstance(expected, list):
        assert len(expected) == len(actual), (
            f"{stack_trace} length mismatch:" f"expect {len(expected)}, get {len(actual)}"
        )
        for i in range(len(expected)):
            assert_json_eq(expected[i], actual[i], stack_trace + f"[{i}]")
    if isinstance(expected, dict):
        assert expected.keys() == actual.keys(), (
            f"{stack_trace} keys mismatch:" f"expect {expected.keys()}, get {actual.keys()}"
        )
        for k in expected.keys():
            key_repr = "." + k if k.isidentifier() else f'["{k}"]'
            assert_json_eq(expected[k], actual[k], stack_trace + key_repr)
    assert expected == actual, f"{stack_trace} value mismatch:" f"expect {expected}, get {actual}"
