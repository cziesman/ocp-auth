#!/bin/bash

# Define special characters
SPECIAL_CHARACTERS='!@#$%^&*()_+[]{}|;:,.<>?/~'

# Use /dev/urandom to generate random data and pipe it to awk
# AWK will extract only characters from SPECIAL_CHARACTERS
password=$(head -c 100 /dev/urandom | awk -v chars="$SPECIAL_CHARACTERS" '
BEGIN {
    split(chars, special_chars, "")
    n = length(special_chars)
}
{
    for (i = 1; i <= length($0); i++) {
        ch = substr($0, i, 1)
        for (j = 1; j <= n; j++) {
            if (ch == special_chars[j]) {
                printf("%s", ch)
            }
        }
    }
}' | head -c 2)

# Output the generated password
echo "Generated password: $password"
