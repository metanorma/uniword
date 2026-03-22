# frozen_string_literal: true

module Uniword
  class WindowsWordImplementation < WordImplementation
    def installed?
      # Check if Word is installed by checking for common paths
      !word_install_path.nil?
    end

    def version
      return nil unless installed?
      # Read version from registry would require win32ole
      # For now, return a placeholder
      'Unknown'
    end

    def themes_path
      return nil unless installed?
      appdata = ENV['APPDATA']
      return nil unless appdata
      File.join(appdata, 'Microsoft', 'Templates', 'Document Themes')
    end

    def stylesets_path
      return nil unless installed?
      appdata = ENV['APPDATA']
      return nil unless appdata
      File.join(appdata, 'Microsoft', 'QuickStyles')
    end

    def color_schemes_path
      return nil unless installed?
      appdata = ENV['APPDATA']
      return nil unless appdata
      File.join(appdata, 'Microsoft', 'Templates', 'Document Themes', 'Theme Colors')
    end

    def font_schemes_path
      return nil unless installed?
      appdata = ENV['APPDATA']
      return nil unless appdata
      File.join(appdata, 'Microsoft', 'Templates', 'Document Themes', 'Theme Fonts')
    end

    def cache_path
      appdata = ENV['APPDATA'] || ENV['HOME'] || '.'
      File.join(appdata, '.uniword')
    end

    private

    def word_install_path
      # Check common Word installation paths on Windows
      program_files = ENV['ProgramFiles'] || 'C:\Program Files'
      program_files_x86 = ENV['ProgramFiles(x86)'] || 'C:\Program Files (x86)'

      # Try to find Word executable
      [
        File.join(program_files, 'Microsoft Office', 'root', 'Office16', 'WINWORD.EXE'),
        File.join(program_files_x86, 'Microsoft Office', 'root', 'Office16', 'WINWORD.EXE'),
        File.join(program_files, 'Microsoft Office', 'Office16', 'WINWORD.EXE'),
        File.join(program_files_x86, 'Microsoft Office', 'Office16', 'WINWORD.EXE')
      ].find { |path| File.exist?(path) }
    end
  end
end
