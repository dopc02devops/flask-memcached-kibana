#!/bin/bash

# Variables
USERNAME="kube_user"
SSH_KEY="ssh-rsa BBBBBBBBAAAAB3NzaC1yc2EAAAADAQABAAACAQCVG5b1Eb1+VRWgWm7rVYk6SwqTClBkqYGN728UkOnuIsk698KIQvFDiGSFkMGGvkNB8loK9cnW4o9jLJIWAuv8HviaOthb0YtNY32plzAQigKT322JjC2iCuomMCfZqQJK/BO5Dzh2wZN3/IzhytCPkScPSKQ27Ra/bRhpxbUxKRazOAB02wT2Zed5XUsP13L+paDQG5f/iIePqLUN5kVna8QXHHFKT98ZpmRII7M6PmxuCpdSuCaq6FFiK8kJ/RoYjZ8K3BuxySni1iuvqM8ESb8eE23vtxOHqRZqUw7lGwvKQeZwWToiPZcgBTpdDf/19fARjv9CWywaVyv0kKRSGBBOpotHxazOY+u8t94gLVwD0fRtMqrSvtisSbJTEq36l9udREPZQ2DcKwrXtyozIbTus5fVs3xeTtgkwolU+qH+xOUCv4uaYOy9U0dY6qe5PhQURckGjUqu0KXJIysSK68YQhfAAVDXnB6k6Lt6T3CzFEaNFtMbTrrlShh80cZX9uVkPLJ7KSqFoIT8mliLwCiGKnYi/v619CRl45vKXJPvMd/daWmVr+7SQndKsdUxBM7eyVYeJpujpZlEdbzgqVDwkVfa3jdzrKDMnMKAWQe9iuUCWuPD8CybOaZIpj1ipSq2zjDsMK3yMn5fCNJUg4PHHwbmkuFlm41YITKTMw== terraform"

# Check if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists."
    exit 1
fi

# Add user and set up SSH access
useradd -m -s /bin/bash "$USERNAME" || { echo "Error: Failed to create user."; exit 1; }
mkdir -p /home/"$USERNAME"/.ssh
echo "$SSH_KEY" > /home/"$USERNAME"/.ssh/authorized_keys
chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh
chmod 700 /home/"$USERNAME"/.ssh
chmod 600 /home/"$USERNAME"/.ssh/authorized_keys

# Grant sudo privileges
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo

# Output status
echo "SSH user '$USERNAME' created and configured successfully."