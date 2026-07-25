String shortId(String value) =>
    value.length <= 8 ? value : value.substring(0, 8);
