Frame
<p align="center">
<img src="assets/icon/frame_logo.png" alt="Frame Logo" width="160" height="160">
</p>
<p align="center">
<b>A modern, offline-first PSD previewer, font manager, and design asset utility built with Flutter for graphic designers.</b>
</p>
About Frame
Frame bridges the gap between heavy desktop design workflows and mobile accessibility. Designed with performance, privacy, and simplicity in mind, Frame allows graphic designers, creators, and developers to manage, inspect, and export their design assets directly from their mobile devices—without needing a resource-heavy computer or expensive desktop software installed.
Whether you are managing local .psd files on your device storage or organizing custom font families, Frame provides a clean, lightning-fast workspace complete with adaptive dynamic themes and smart offline-first capabilities.
Core Features
1. Local PSD Auto-Scanner & Inspector
 * Automatic Discovery: Instantly scans device storage for .psd files without manual searching.
 * Metadata & Layer Analysis: View file resolution, exact dimensions in pixels, color channel information, and file modification timestamps.
 * In-App Renaming: Quickly rename design files directly within the app interface.
 * Instant Export: Convert and export .psd files instantly into high-quality PNG or JPEG formats for quick client previews and sharing.
2. Intelligent Color Palette Extractor (Swatch Generator)
 * Dominant Color Extraction: Automatically analyzes opened .psd files and extracts the main color swatches.
 * Palette Generation: Instantly generates clean color palettes so designers can reference or utilize dominant hex/RGB codes on the go.
3. Typography & Font Manager
 * Font Catcher: Automatically detects local font packages including .ttf, .otf, and zipped font bundles (.zip).
 * Live Previews: Test font renderings instantly with clean typography displays.
4. Hybrid Online-Offline Engine
 * Offline-First Architecture: Operates seamlessly without an internet connection, ensuring local storage management never lags or fails.
 * Smart Cloud Integration: Securely connect and sync remote asset folders via Google Drive and Dropbox when online. If connectivity drops, cloud features gracefully pause while local tools continue running without interruption.
5. Contextual Time Greetings & Flash Festival Wishes
 * Smart Time-Based Welcome: Automatically detects device time to greet users dynamically (Good Morning, Afternoon, Evening, or Night) along with personalized user recognition.
 * Flash Festival Banner: Built-in date synchronization automatically triggers festive greeting banners and subtle theme accents across major Indian and international festivals (Diwali, Holi, New Year, Christmas, Independence Day, etc.).
6. Dynamic Theme Switcher
 * Triple Mode Support: Switch seamlessly between Light Mode, Dark Mode, and true black OLED Night Mode.
 * Persistent Preferences: Remembers your preferred theme across app launches.
Tech Stack & Architecture
 * Framework: Flutter (Dart) for high-performance, cross-platform compilation.
 * Typography: Inter font family for clean, professional, and modern designer aesthetics.
 * Storage & Processing: path_provider, permission_handler, archive, and image packages for native file handling and bitmap rendering.
 * CI/CD: Automated builds via GitHub Actions for effortless release generation.
Getting Started
 * Clone the repository:
   git clone https://github.com/your-username/frame.git

 * Install dependencies:
   flutter pub get

 * Run the app:
   flutter run

License
This project is open-source software licensed under the MIT License.
