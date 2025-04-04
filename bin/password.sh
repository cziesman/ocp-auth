#!/bin/bash

# Set locale to avoid 'illegal byte sequence' errors
export LC_ALL=C

# Password rules
MIN_LENGTH=12
SPECIAL_CHARACTERS="@#$%^&*()_+-=[]{}|;:,.<>?"
DICTIONARY_FILE="/usr/share/dict/words"  # Adjust path to your dictionary if needed

get_specials() {
  return $(cat /dev/urandom | awk -v chars="$SPECIAL_CHARACTERS" '
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
}

# Function to generate a secure password
generate_password() {
    while true; do
        # Generate 1 lowercase letter
        lower=$(tr -dc 'a-z' < /dev/urandom | head -c 1)

        # Generate 1 uppercase letter
        upper=$(tr -dc 'A-Z' < /dev/urandom | head -c 1)

        # Generate 1 digit
        digit=$(tr -dc '0-9' < /dev/urandom | head -c 1)

        # Generate 2 special characters
        special=get_specials
        echo "$special"

        # Calculate remaining characters
        remaining_length=$((MIN_LENGTH - ${#lower} - ${#upper} - ${#digit} - ${#special}))

        # Generate the remaining length of the password with alphanumeric characters
        remaining=$(tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$remaining_length")

        # Combine all parts into a password (no shuffling)
        password="$lower$upper$digit$special$remaining"

        # Ensure password length is at least MIN_LENGTH
        if [ ${#password} -lt $MIN_LENGTH ]; then
            continue
        fi

        # Check if password matches a dictionary word (case-insensitive)
        if [ -f "$DICTIONARY_FILE" ] && echo "$password" | grep -iqF "$password" "$DICTIONARY_FILE"; then
            continue  # Regenerate if password is found in dictionary
        fi

        # Return the password
        echo "$password"
        break  # Exit loop after generating a valid password
    done
}


# Generate a password
generate_password
