<div align="center">

# 🛠️ Crafting Bench 🛠️ 

[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell Script](https://img.shields.io/badge/Shell_Script-Bash-4EAA25.svg?logo=gnu-bash&logoColor=white)](craftingbench.sh)
[![Made with Love](https://img.shields.io/badge/Made%20with-Love-ff69b4.svg)](https://github.com/ahmifte/craftingbench)

</div>

---

<br />

<div align="center">
  <p><em><strong>Craft your projects with precision and speed</strong></em></p>
  A powerful utility for quickly scaffolding various project types with standardized, production-ready structures.
</div>

<br />

<div align="center">

```
                                                                           
      #@@++++++++++++++++++++++++++++++++++++++++++++++++++++==-+*@@@      
    :@@*+++++++++++++++++++++++++++++++++++++++++++++++++++++++===*#@@#    
   @@#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++==-+*#@@   
 @@*-:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::.-=*@@ 
 @@@@@@@@%%@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@%%%@@@@@@ 
 @@@@@@@@*@@#@%@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@*@@*@@@@@@@ 
        %.@  -#@                                            =@@  @:#       
       =@-@  @@@                                            +@@  @=@=      
       %%:@  @@#                                            .@@  @+@*      
       @*-@  @@.                                             @@  @*#%      
       @++@  @@                                              @@. @%*@      
       @+%@ .@@                                              @@= #@+@      
       @=@% *@@                                              @@# -@=@      
       @-@: @@@                                              @@@  @-@      
       @=@  @@@                                              @@@  @-@      
      -@=@  @@@                                              %@@  @=@:     
      +@=@  @@=                                               @@  @=@#     
      #%+@                                                        @*#@     
      @##@                                                        @%+@     
      @+@@                                                        @@=@     
      @=@*                                                        %@-@     
      @-@:                                                        =@-@     
                                                                           
```

</div>

---

<br />

## ✨ Features

CraftingBench provides templates for various project types:

- **Python Projects**: Modern Python package with testing, linting, and CI/CD setup
- **Node.js Backend**: Express-based API with TypeScript and testing framework
- **Golang API**: Go-based REST API with standard project layout
- **Full-Stack Web (Next.js)**: Next.js app with built-in API routes and state management (coming soon)
- **React Frontend**: TypeScript + React application with modern tooling (coming soon)

## 📂 Project Structure

CraftingBench has been organized into a modular structure for better maintainability:

```
craftingbench/
├── craftingbench.sh         # Main entry point script
├── src/                     # Source code
│   ├── helpers/             # Helper functions
│   ├── templates/           # Project templates
│   └── completions/         # Shell completions
├── docs/                    # Documentation
└── README.md                # Main documentation
```

For more information, see [Architecture Documentation](docs/architecture.md).

## 🚀 Installation

1. Clone this repository:
```bash
git clone https://github.com/ahmifte/craftingbench.git
```

2. Make the script executable:
```bash
chmod +x /path/to/craftingbench/craftingbench.sh
```

3. Add the following to your shell configuration file:

**For Bash users** (`.bashrc`