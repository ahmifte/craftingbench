#!/usr/bin/env bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CLEAR='\033[0m'

echo -e "${BLUE}=== Setting up the project with uv and Anthropic SDK ===${CLEAR}"

# Step 1: Install uv
echo -e "${BLUE}Installing uv (fast Python package manager)...${CLEAR}"
if command -v uv &> /dev/null; then
    echo -e "${GREEN}uv is already installed!${CLEAR}"
else
    echo -e "${YELLOW}Installing uv...${CLEAR}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for the current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Check if uv was installed successfully
    if command -v uv &> /dev/null; then
        echo -e "${GREEN}uv has been successfully installed!${CLEAR}"
    else
        echo -e "${RED}Failed to install uv. Please check the installation manually.${CLEAR}"
        exit 1
    fi
fi

# Step 2: Create a virtual environment with uv
echo -e "${BLUE}Creating a virtual environment...${CLEAR}"
uv venv .venv

# Step 3: Activate the virtual environment
echo -e "${BLUE}Activating the virtual environment...${CLEAR}"
source .venv/bin/activate

# Step 4: Install Anthropic Python SDK and other dependencies
echo -e "${BLUE}Installing Anthropic Python SDK and other dependencies...${CLEAR}"
uv pip install anthropic

# Step 5: Create an example script for using Anthropic/Claude
echo -e "${BLUE}Creating an example script for using Anthropic/Claude...${CLEAR}"

cat > anthropic_example.py << 'EOL'
#!/usr/bin/env python3

import os
import anthropic

def main():
    # Check if API key is set
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print("Please set your ANTHROPIC_API_KEY environment variable")
        print("Example: export ANTHROPIC_API_KEY='your-api-key-here'")
        return
    
    # Initialize the Anthropic client
    client = anthropic.Anthropic(
        api_key=api_key,
    )
    
    # Example message to Claude
    message = client.messages.create(
        model="claude-3-5-sonnet-20240620",
        max_tokens=1000,
        messages=[
            {"role": "user", "content": "Hello Claude! What can you help me with today?"}
        ]
    )
    
    # Print the response
    print(message.content)

if __name__ == "__main__":
    main()
EOL

chmod +x anthropic_example.py

# Step 6: Create a README for the Anthropic integration
echo -e "${BLUE}Creating a README for the Anthropic integration...${CLEAR}"

cat > ANTHROPIC_README.md << 'EOL'
# Anthropic Claude Integration

This integration allows you to use Anthropic's Claude API in your CraftingBench project.

## Prerequisites

- Python 3.7 or higher
- An Anthropic API key (get one from [https://console.anthropic.com/](https://console.anthropic.com/))

## Getting Started

1. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```

2. Set your Anthropic API key:
   ```bash
   export ANTHROPIC_API_KEY='your-api-key-here'
   ```

3. Run the example script:
   ```bash
   ./anthropic_example.py
   ```

## Using Claude in Your Project

```python
import anthropic

# Initialize the client
client = anthropic.Anthropic()

# Create a message
response = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    messages=[
        {"role": "user", "content": "Your prompt here"}
    ]
)

print(response.content)
```

For more information, see the [Anthropic Python SDK documentation](https://docs.anthropic.com/en/docs/initial-setup).
EOL

# Create a simple requirements.txt for future reference
echo -e "${BLUE}Creating requirements.txt file...${CLEAR}"
cat > requirements.txt << 'EOL'
anthropic>=0.17.0
EOL

echo -e "${GREEN}Setup complete!${CLEAR}"
echo -e "${YELLOW}To get started:${CLEAR}"
echo -e "1. Activate the virtual environment: ${BLUE}source .venv/bin/activate${CLEAR}"
echo -e "2. Set your Anthropic API key: ${BLUE}export ANTHROPIC_API_KEY='your-api-key-here'${CLEAR}"
echo -e "3. Run the example script: ${BLUE}./anthropic_example.py${CLEAR}"
echo -e "4. See ${BLUE}ANTHROPIC_README.md${CLEAR} for more details" 