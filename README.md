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
- **React Frontend**: TypeScript + React application with modern tooling
- **Full-Stack Web (Next.js)**: Next.js app with built-in API routes and state management

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

**For Bash users** (`.bashrc`):
```bash	
source /path/to/craftingbench/craftingbench.sh	
```	

**For Zsh users** (`.zshrc`):	
```zsh	
# Load CraftingBench	
source /path/to/craftingbench/craftingbench.sh	

# Optional: Enable Zsh completion for CraftingBench commands	
compdef _gnu_generic setup_python_project setup_nodejs_backend setup_react_frontend setup_go_project setup_fullstack_project	
```	

4. Reload your shell configuration:	

**For Bash users**:	
```bash	
source ~/.bashrc	
```	

**For Zsh users**:	
```zsh	
source ~/.zshrc	
# Or use the shorthand	
. ~/.zshrc	
```	

## 📋 Usage	

Each project template is created with a single command:	

### Python Project	

```bash	
setup_python_project my_awesome_package	
```	

Generated structure:	
```	
my_awesome_package/	
├── .gitignore	
├── .python-version	
├── Makefile	
├── README.md	
├── main.py	
├── my_awesome_package/	
│   └── __init__.py	
├── pyproject.toml	
└── tests/	
    └── test_main.py	
```	

### Node.js Backend (Express)	

```bash	
setup_nodejs_backend my_api_service	
```	

Generated structure:	
```	
my_api_service/	
├── .eslintrc.js	
├── .gitignore	
├── README.md	
├── package.json	
├── src/	
│   ├── index.js	
│   ├── controllers/	
│   ├── models/	
│   ├── routes/	
│   └── middleware/	
└── tests/	
```	

### Golang API	

```bash	
setup_go_project my_go_service	
```	

Generated structure:	
```	
my_go_service/	
├── .gitignore	
├── Makefile	
├── README.md	
├── cmd/	
│   └── my_go_service/	
│       └── main.go	
├── go.mod	
├── internal/	
│   ├── app/	
│   └── pkg/	
├── pkg/	
└── test/	
```	

### React Frontend

```bash
setup_react_frontend my_react_app
```

Generated structure:
```
my_react_app/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── public/
│   ├── index.html
│   └── favicon.ico
├── src/
│   ├── App.tsx
│   ├── index.tsx
│   ├── components/
│   └── styles/
└── tsconfig.json
```

### Full-Stack Web (Next.js)

```bash
setup_fullstack_project my_nextjs_app
```

Generated structure:
```
my_nextjs_app/
├── .eslintrc.js
├── .gitignore
├── README.md
├── package.json
├── public/
│   └── favicon.ico
├── src/
│   ├── pages/
│   │   ├── index.tsx
│   │   ├── _app.tsx
│   │   └── api/
│   ├── components/
│   └── styles/
└── tsconfig.json
```

## 🧪 Testing and Quality Assurance	

Each project template includes built-in testing capabilities:	

### Python Projects	

```bash	
cd my_python_project	
make test      # Runs pytest	
make lint      # Runs flake8	
make format    # Runs black and isort	
```	

### Node.js Projects	

```bash	
cd my_node_project	
npm run test   # Runs tests	
npm run lint   # Runs ESLint	
```	

### Go Projects	

```bash	
cd my_go_project	
make test      # Runs go test	
make vet       # Runs go vet	
make fmt       # Runs go fmt	
```	

### React Projects

```bash
cd my_react_app
npm run test   # Runs Jest tests
npm run lint   # Runs ESLint
npm run build  # Creates production build
```

### Next.js Projects

```bash
cd my_nextjs_app
npm run test   # Runs Jest tests
npm run lint   # Runs ESLint
npm run build  # Creates production build
npm run dev    # Starts development server
```

## 🤝 Contributing	

Contributions are welcome! Feel free to add new project templates or improve existing ones.	

1. Fork the repository	
2. Create your feature branch (`git checkout -b feature/amazing-template`)	
3. Commit your changes (`git commit -m 'Add amazing template'`)	
4. Push to the branch (`git push origin feature/amazing-template`)	
5. Open a Pull Request	

### Development	

To add a new template, see our [Template Documentation](docs/templates/README.md).	

## 📚 Resources	

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Python Project Structure Guide](https://docs.python-guide.org/writing/structure/)	
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)	
- [Go Project Layout](https://github.com/golang-standards/project-layout)	
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)	

## 📜 License	

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 	
