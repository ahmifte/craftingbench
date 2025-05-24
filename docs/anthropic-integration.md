# Anthropic Claude Integration

This document describes how to integrate Anthropic's Claude into your CraftingBench project.

## Overview

CraftingBench provides a simple way to set up Anthropic's Claude API in your project using our setup script.

## Setup

To set up Claude in your project, run:

```bash
./src/scripts/setup_anthropic_with_uv.sh
```

This will:
1. Install `uv` (fast Python package manager) if not already installed
2. Create a Python virtual environment
3. Install the Anthropic Python SDK
4. Create example code to get you started
5. Generate documentation

## Prerequisites

- Python 3.7 or higher
- An Anthropic API key (obtain one from [console.anthropic.com](https://console.anthropic.com/))

## Using Claude in Your Project

After running the setup script:

1. Activate the virtual environment:
   ```bash
   source .venv/bin/activate
   ```

2. Set your Anthropic API key:
   ```bash
   export ANTHROPIC_API_KEY='your-api-key-here'
   ```

3. Use the provided example script or integrate the code into your project:
   ```bash
   ./anthropic_example.py
   ```

## API Example

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

## Resources

- [Anthropic Python SDK Documentation](https://docs.anthropic.com/en/docs/initial-setup)
- [Claude API Reference](https://docs.anthropic.com/en/api/reference) 