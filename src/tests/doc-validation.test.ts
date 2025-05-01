import * as fs from 'fs';
import * as path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

// Project root path
const rootPath = path.resolve(__dirname, '../../');

// Test directory for template output
const testOutputDir = path.join(__dirname, 'test-output');

// Paths to documentation files
const readmePath = path.join(rootPath, 'README.md');
const docsDirPath = path.join(rootPath, 'docs');
const templatesDocPath = path.join(docsDirPath, 'templates', 'README.md');

// Ensure test directory exists
beforeAll(() => {
  if (!fs.existsSync(testOutputDir)) {
    fs.mkdirSync(testOutputDir, { recursive: true });
  }
});

// Clean up after tests
afterAll(() => {
  // Optionally remove test output directory after tests
  // fs.rmSync(testOutputDir, { recursive: true, force: true });
});

// Helper function to execute a CraftingBench command
async function runCraftingBenchCommand(command: string): Promise<string> {
  try {
    const { stdout } = await execAsync(
      `cd ${rootPath} && source ./craftingbench.sh && cd ${testOutputDir} && ${command}`
    );
    return stdout.trim();
  } catch (error) {
    console.error(`Error executing command: ${command}`, error);
    throw error;
  }
}

// Helper function to read file content
function readFileContent(filePath: string): string {
  return fs.readFileSync(filePath, 'utf8');
}

// Helper to check if string contains key phrases
function containsKeyPhrases(content: string, phrases: string[]): boolean {
  return phrases.every(phrase => content.includes(phrase));
}

describe('Documentation validation', () => {
  // Read documentation files
  const readmeContent = readFileContent(readmePath);
  let templatesDocContent = '';

  try {
    templatesDocContent = readFileContent(templatesDocPath);
  } catch (error) {
    // Templates doc might not exist
    console.warn('Templates documentation not found:', error);
  }

  describe('README.md validation', () => {
    test('README contains all template types', () => {
      expect(readmeContent).toContain('Python Projects');
      expect(readmeContent).toContain('Node.js Backend');
      expect(readmeContent).toContain('Golang API');
      expect(readmeContent).toContain('React Frontend');
      expect(readmeContent).toContain('Full-Stack Web');
    });

    test('README lists all available commands', () => {
      expect(readmeContent).toContain('setup_python_project');
      expect(readmeContent).toContain('setup_nodejs_backend');
      expect(readmeContent).toContain('setup_react_frontend');
      expect(readmeContent).toContain('setup_go_project');
      expect(readmeContent).toContain('setup_fullstack_project');
    });

    test('README mentions full-stack backend options', () => {
      expect(readmeContent).toContain('--backend=nextjs');
      expect(readmeContent).toContain('--backend=flask');
      expect(readmeContent).toContain('--backend=golang');
    });

    test('README version matches craftingbench.sh version', () => {
      const readmeVersion = readmeContent.match(/Version-([0-9.]+)/)?.[1] || '';
      const scriptContent = readFileContent(path.join(rootPath, 'craftingbench.sh'));
      const scriptVersion = scriptContent.match(/Version: ([0-9.]+)/)?.[1] || '';

      expect(readmeVersion).not.toBe('');
      expect(scriptVersion).not.toBe('');
      expect(readmeVersion).toBe(scriptVersion);
    });
  });

  describe('Python project template validation', () => {
    const projectName = 'test-python-validate';
    const outputPath = path.join(testOutputDir, projectName);

    beforeAll(async () => {
      if (!fs.existsSync(outputPath)) {
        await runCraftingBenchCommand(`setup_python_project ${projectName}`);
      }
    });

    test('Python project matches documentation', () => {
      // Check if project was created
      expect(fs.existsSync(outputPath)).toBe(true);

      // Check for key files mentioned in documentation
      expect(fs.existsSync(path.join(outputPath, 'pyproject.toml'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'README.md'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'tests'))).toBe(true);

      // Validate README contains correct project name
      const projectReadme = readFileContent(path.join(outputPath, 'README.md'));
      expect(projectReadme).toContain(projectName);
    });
  });

  describe('Node.js project template validation', () => {
    const projectName = 'test-node-validate';
    const outputPath = path.join(testOutputDir, projectName);

    beforeAll(async () => {
      if (!fs.existsSync(outputPath)) {
        await runCraftingBenchCommand(`setup_nodejs_backend ${projectName}`);
      }
    });

    test('Node.js project matches documentation', () => {
      // Check if project was created
      expect(fs.existsSync(outputPath)).toBe(true);

      // Check for key files mentioned in documentation
      expect(fs.existsSync(path.join(outputPath, 'package.json'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'tsconfig.json'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'src'))).toBe(true);

      // Validate package.json contains TypeScript as mentioned in docs
      const packageJson = JSON.parse(readFileContent(path.join(outputPath, 'package.json')));
      expect(packageJson.devDependencies).toHaveProperty('typescript');
    });
  });

  describe('React project template validation', () => {
    const projectName = 'test-react-validate';
    const outputPath = path.join(testOutputDir, projectName);

    beforeAll(async () => {
      if (!fs.existsSync(outputPath)) {
        await runCraftingBenchCommand(`setup_react_frontend ${projectName}`);
      }
    });

    test('React project matches documentation', () => {
      // Check if project was created
      expect(fs.existsSync(outputPath)).toBe(true);

      // Check for key files mentioned in documentation
      expect(fs.existsSync(path.join(outputPath, 'package.json'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'tsconfig.json'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'src'))).toBe(true);

      // Validate package.json contains Material UI as mentioned in docs
      const packageJson = JSON.parse(readFileContent(path.join(outputPath, 'package.json')));

      // Check if either the old @material-ui or new @mui packages are present
      const hasMaterialUI = Object.keys(packageJson.dependencies).some(
        dep => dep.includes('@material-ui') || dep.includes('@mui')
      );

      expect(hasMaterialUI).toBe(true);
    });
  });

  describe('Golang project template validation', () => {
    const projectName = 'test-go-validate';
    const outputPath = path.join(testOutputDir, projectName);

    beforeAll(async () => {
      if (!fs.existsSync(outputPath)) {
        await runCraftingBenchCommand(`setup_go_project ${projectName}`);
      }
    });

    test('Go project matches documentation', () => {
      // Check if project was created
      expect(fs.existsSync(outputPath)).toBe(true);

      // Check for key directories mentioned in documentation
      expect(fs.existsSync(path.join(outputPath, 'cmd'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'internal'))).toBe(true);
      expect(fs.existsSync(path.join(outputPath, 'pkg'))).toBe(true);

      // Validate go.mod contains correct module name
      const goMod = readFileContent(path.join(outputPath, 'go.mod'));
      expect(goMod).toContain(`module ${projectName}`);
    });
  });

  describe('Fullstack project template validation', () => {
    const backendOptions = ['nextjs', 'flask', 'golang'];

    for (const backend of backendOptions) {
      describe(`Fullstack with ${backend} backend`, () => {
        const projectName = `test-fullstack-${backend}-validate`;
        const outputPath = path.join(testOutputDir, projectName);

        beforeAll(async () => {
          if (!fs.existsSync(outputPath)) {
            await runCraftingBenchCommand(
              `setup_fullstack_project ${projectName} --backend=${backend}`
            );
          }
        });

        test(`${backend} fullstack project matches documentation`, () => {
          // Check if project was created
          expect(fs.existsSync(outputPath)).toBe(true);

          // Check README
          expect(fs.existsSync(path.join(outputPath, 'README.md'))).toBe(true);

          if (backend === 'nextjs') {
            // Next.js is a unified project
            expect(fs.existsSync(path.join(outputPath, 'package.json'))).toBe(true);
            expect(fs.existsSync(path.join(outputPath, 'tsconfig.json'))).toBe(true);
          } else {
            // Other backends have separate frontend/backend folders
            expect(fs.existsSync(path.join(outputPath, 'frontend'))).toBe(true);
            expect(fs.existsSync(path.join(outputPath, 'backend'))).toBe(true);

            // Frontend should have React with TypeScript
            expect(fs.existsSync(path.join(outputPath, 'frontend', 'package.json'))).toBe(true);
            expect(fs.existsSync(path.join(outputPath, 'frontend', 'tsconfig.json'))).toBe(true);

            // Backend specific checks
            if (backend === 'flask') {
              expect(fs.existsSync(path.join(outputPath, 'backend', 'requirements.txt'))).toBe(
                true
              );
            } else if (backend === 'golang') {
              expect(fs.existsSync(path.join(outputPath, 'backend', 'go.mod'))).toBe(true);
            }
          }
        });
      });
    }
  });
});
