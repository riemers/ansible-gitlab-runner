def first_or_value(value, default=None):
    """Return: the first element when value is list or tuple, otherwise value (or default when value is None or empty list/tuple)"""
    if value is None:
        return default
    if isinstance(value, (list, tuple)):
        return value[0] if value else default
    return value

class FilterModule(object):
    def filters(self):
        return {
            'first_or_value': first_or_value,
        }
