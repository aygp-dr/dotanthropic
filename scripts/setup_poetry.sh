# First create a new poetry project if you haven't already
poetry init 

# Add aider
poetry add aider-chat

# Add Simon Willison's tools
poetry add llm
poetry add ttok
poetry add strip-tags
poetry add files-to-prompt

# Optional: Add common development dependencies
poetry add --group dev pytest black isort

# If you want to install them all at once, you can use:
poetry add aider-chat llm ttok strip-tags

# Verify installations
poetry run aider --version
poetry run llm --version
poetry run ttok --version
poetry run strip-tags --version

# Set up OpenAI API key for llm
poetry run llm keys set openai

# Example usage within Poetry environment
poetry run llm "Hello, world!"
poetry run ttok "Count these tokens"
poetry run strip-tags < input.html

# For Emacs users, make sure aider.el points to Poetry's aider:
# Add this to your Emacs configuration:
# (setq aider-executable "/path/to/poetry/env/bin/aider")

# See installed packages
poetry show

# Export dependencies to requirements.txt (if needed)
poetry export -f requirements.txt --output requirements.txt
