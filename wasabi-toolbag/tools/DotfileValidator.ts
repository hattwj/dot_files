// IMPORTANT: Only use node: prefixed imports for Node.js built-ins
import { exec } from "node:child_process";

// Type definition for the context parameter - this is injected by Wasabi
// IMPORTANT: Always include this ToolContext interface in the tool file
interface ToolContext {
  // File system operations
  readonly fs: typeof import("node:fs");
  readonly path: typeof import("node:path");
  readonly os: typeof import("node:os");
  readonly process: typeof import("node:process");

  // HTTP client for internal Amazon services (authenticated with Midway)
  // Use this for making authenticated requests to internal services
  readonly httpClient: {
    request<TInput = unknown, TOutput = unknown>(
      url: URL,
      method: "GET" | "POST" | "PUT" | "DELETE" | "PATCH" | "HEAD",
      options?: {
        timeout?: number;
        retryStrategy?: { maxAttempts: number; maxElapsedTime: number };
        body?: TInput;
        headers?: Record<string, string>;
        compression?: "gzip" | "br";
        doNotParse?: TOutput extends Buffer ? boolean : never;
      }
    ): Promise<{
      statusCode: number;
      headers: Record<string, string | string[] | undefined>;
      body: TOutput
    }>;
  };
  readonly rootDir: string;
  readonly validFileGlobs: string[];
  readonly excludedFileGlobs: string[];

  readonly bedrock: {
    prompt(promptParams: {
      inputs: BedrockMessage[];
      system?: { text: string }[];
      inferenceConfig?: {
        maxTokens?: number;
        temperature?: number;
        topP?: number;
      };
    }): Promise<{
      stopReason?: string;
      tokensUsed?: number;
      // This will include inputs and new messages from inference
      messages: BedrockMessage[];
    }>;
  }
}

// IMPORTANT: Always include this type in the tool file
type BedrockMessage = {
  role: "user" | "assistant" | string;
  content: Array<{
    text?: string;
    document?: {
      name: string;
      content: string;
    };
    toolUse?: {
      name: string;
      input: string;
    };
    toolResult?: {
      name: string;
      status: "success" | "error";
      content: Array<{
        text?: string;
        document?: {
          name: string;
          content: string;
        };
      }>;
    };
  }>;
};

// CRITICAL: Define a strict interface for your tool's parameters
interface DotfileValidatorParams {
  configType?: "vim" | "nvim" | "tmux" | "shell" | "all";
  configPath?: string;
  checkSyntax?: boolean;
  checkReferences?: boolean;
}

/**
 * IMPORTANT IMPLEMENTATION REQUIREMENTS:
 * 1. Tool MUST be the default export
 * 2. Tool MUST be a class (not a function or object)
 * 3. Class name MUST match the tool name property
 * 4. Tool name MUST be unique across all tools (including built-in tools)
 * 5. Tool MUST have an execute method
 * 6. Tool MUST have an inputSchema with a json property containing the JSON Schema
 */
class DotfileValidator {
  // REQUIRED: Constructor must accept ToolContext
  constructor(private readonly context: ToolContext) {}

  // REQUIRED: Name property should match the class name
  public readonly name = "DotfileValidator";

  // REQUIRED: Schema defining the expected input parameters
  public readonly inputSchema = {
    json: {
      type: "object",
      properties: {
        configType: {
          type: "string",
          enum: ["vim", "nvim", "tmux", "shell", "all"],
          description: "Type of configuration to validate (default: all)"
        },
        configPath: {
          type: "string",
          description: "Specific path to configuration file (optional, overrides configType)"
        },
        checkSyntax: {
          type: "boolean",
          description: "Whether to perform syntax validation (default: true)"
        },
        checkReferences: {
          type: "boolean",
          description: "Whether to check file references and dependencies (default: true)"
        }
      },
      additionalProperties: false
    }
  } as const;

  // REQUIRED: Description of what the tool does
  public readonly description =
    "Validates dotfile configurations for syntax errors, missing dependencies, and broken references";

  // REQUIRED: execute method that implements the tool's functionality
  public async execute(params: DotfileValidatorParams) {
    const {
      configType = "all",
      configPath,
      checkSyntax = true,
      checkReferences = true
    } = params;

    const results: any[] = [];

    try {
      if (configPath) {
        // Validate specific file
        const result = await this.validateFile(configPath, checkSyntax, checkReferences);
        results.push(result);
      } else {
        // Validate by type
        const configPaths = this.getConfigPaths(configType);
        for (const path of configPaths) {
          if (this.context.fs.existsSync(path)) {
            const result = await this.validateFile(path, checkSyntax, checkReferences);
            results.push(result);
          }
        }
      }

      const totalIssues = results.reduce((sum, r) => sum + r.issues.length, 0);

      return {
        status: "success",
        message: `Dotfile validation completed. Found ${totalIssues} issues across ${results.length} files.`,
        summary: {
          filesChecked: results.length,
          totalIssues,
          passedFiles: results.filter(r => r.issues.length === 0).length,
          failedFiles: results.filter(r => r.issues.length > 0).length
        },
        results
      };

    } catch (error: any) {
      return {
        status: "error",
        message: "Error during dotfile validation",
        error: error.message
      };
    }
  }

  private getConfigPaths(configType: string): string[] {
    const basePaths = {
      vim: ["configs/.vimrc", "backups/.vimrc"],
      nvim: [
        "configs/.config/nvim/init.lua",
        "configs/.config/nvim/lua/config/options.lua",
        "configs/.config/nvim/lua/config/keymaps.lua",
        "configs/.config/nvim/lua/config/autocmds.lua"
      ],
      tmux: ["configs/.tmux.conf", "backups/.tmux.conf"],
      shell: ["configs/.flake8", "configs/.rspec", "configs/.rubocop.yml"],
      all: []
    };

    if (configType === "all") {
      return Object.values(basePaths).flat().filter(p => p);
    }

    return basePaths[configType as keyof typeof basePaths] || [];
  }

  private async validateFile(filePath: string, checkSyntax: boolean, checkReferences: boolean) {
    const fullPath = this.context.path.join(this.context.rootDir, filePath);
    const issues: string[] = [];

    try {
      // Check file exists and is readable
      if (!this.context.fs.existsSync(fullPath)) {
        issues.push(`File does not exist: ${filePath}`);
        return { file: filePath, issues };
      }

      const content = this.context.fs.readFileSync(fullPath, 'utf8');

      // Syntax validation based on file type
      if (checkSyntax) {
        const syntaxIssues = await this.checkSyntax(filePath, content);
        issues.push(...syntaxIssues);
      }

      // Reference validation
      if (checkReferences) {
        const refIssues = this.checkReferences(filePath, content);
        issues.push(...refIssues);
      }

      return { file: filePath, issues };

    } catch (error: any) {
      issues.push(`Error reading file: ${error.message}`);
      return { file: filePath, issues };
    }
  }

  private async checkSyntax(filePath: string, content: string): Promise<string[]> {
    const issues: string[] = [];
    const ext = this.context.path.extname(filePath);

    if (ext === '.lua' || filePath.includes('nvim')) {
      // Lua syntax check
      const luaIssues = await this.validateLuaSyntax(content);
      issues.push(...luaIssues);
    } else if (ext === '.vim' || filePath.includes('.vimrc')) {
      // Vim syntax check
      const vimIssues = this.validateVimSyntax(content);
      issues.push(...vimIssues);
    } else if (filePath.includes('.tmux.conf')) {
      // Tmux config validation
      const tmuxIssues = this.validateTmuxSyntax(content);
      issues.push(...tmuxIssues);
    }

    return issues;
  }

  private async validateLuaSyntax(content: string): Promise<string[]> {
    return new Promise((resolve) => {
      const tempFile = this.context.path.join(this.context.os.tmpdir(), `temp_${Date.now()}.lua`);
      this.context.fs.writeFileSync(tempFile, content);

      exec(`lua -l ${tempFile}`, (error, stdout, stderr) => {
        this.context.fs.unlinkSync(tempFile);

        if (error || stderr) {
          const errorMsg = stderr || error?.message || '';
          const syntaxErrors = errorMsg.split('\n')
            .filter(line => line.includes('syntax error') || line.includes('unexpected'))
            .map(line => `Lua syntax error: ${line.trim()}`);
          resolve(syntaxErrors);
        } else {
          resolve([]);
        }
      });
    });
  }

  private validateVimSyntax(content: string): string[] {
    const issues: string[] = [];
    const lines = content.split('\n');

    lines.forEach((line, index) => {
      const trimmed = line.trim();
      if (trimmed.startsWith('"') || trimmed === '') return; // Skip comments and empty lines

      // Check for common vim syntax errors
      if (trimmed.includes('set ') && !trimmed.match(/^set\s+\w+[=\s]/)) {
        issues.push(`Line ${index + 1}: Potentially malformed 'set' command`);
      }

      // Check for unmatched quotes
      const singleQuotes = (trimmed.match(/'/g) || []).length;
      const doubleQuotes = (trimmed.match(/"/g) || []).length;
      if (singleQuotes % 2 !== 0 || doubleQuotes % 2 !== 0) {
        issues.push(`Line ${index + 1}: Unmatched quotes detected`);
      }
    });

    return issues;
  }

  private validateTmuxSyntax(content: string): string[] {
    const issues: string[] = [];
    const lines = content.split('\n');

    lines.forEach((line, index) => {
      const trimmed = line.trim();
      if (trimmed.startsWith('#') || trimmed === '') return; // Skip comments and empty lines

      // Check for common tmux syntax issues
      if (trimmed.includes('bind') && !trimmed.match(/^bind(-key)?\s+/)) {
        issues.push(`Line ${index + 1}: Potentially malformed 'bind' command`);
      }

      if (trimmed.includes('set') && !trimmed.match(/^set(-option)?\s+/)) {
        issues.push(`Line ${index + 1}: Potentially malformed 'set' command`);
      }
    });

    return issues;
  }

  private checkReferences(filePath: string, content: string): string[] {
    const issues: string[] = [];
    const lines = content.split('\n');

    lines.forEach((line, index) => {
      // Look for file references in various formats
      const fileRefs = line.match(/['"]([\w\/.~-]+)['"]/g);
      if (fileRefs) {
        fileRefs.forEach(ref => {
          const cleanRef = ref.replace(/['"]/g, '');
          if (cleanRef.startsWith('/') || cleanRef.startsWith('~') || cleanRef.startsWith('./')) {
            // Absolute or relative paths - check if they exist
            const fullRefPath = cleanRef.startsWith('~')
              ? cleanRef.replace('~', this.context.os.homedir())
              : this.context.path.resolve(this.context.rootDir, cleanRef);

            if (!this.context.fs.existsSync(fullRefPath)) {
              issues.push(`Line ${index + 1}: Referenced file may not exist: ${cleanRef}`);
            }
          }
        });
      }
    });

    return issues;
  }
}

// REQUIRED: Default export must be the tool class
export default DotfileValidator;
