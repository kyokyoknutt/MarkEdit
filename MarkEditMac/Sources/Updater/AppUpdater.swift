//
//  AppUpdater.swift
//  MarkEditMac
//
//  Created by cyan on 11/1/23.
//

import AppKit
import AppKitExtensions
import MarkEditKit

enum AppUpdater {
  private enum Constants {
    static let endpoint = "https://api.github.com/repos/MarkEdit-app/MarkEdit/releases/latest"
    static let decoder = {
      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      return decoder
    }()
  }

  static func checkForUpdates(explicitly: Bool) async {
    guard let url = URL(string: Constants.endpoint) else {
      return Logger.assertFail("Failed to create the URL: \(Constants.endpoint)")
    }

    guard let (data, response) = try? await URLSession.shared.data(from: url) else {
      return Logger.log(.error, "Failed to reach out to the server")
    }

    guard let status = (response as? HTTPURLResponse)?.statusCode, status == 200 else {
      if explicitly {
        DispatchQueue.main.async {
          presentError()
        }
      }

      return Logger.log(.error, "Failed to get the update")
    }

    guard let version = try? Constants.decoder.decode(AppVersion.self, from: data) else {
      return Logger.log(.error, "Failed to decode the data")
    }

    DispatchQueue.main.async {
      presentUpdate(newVersion: version, explicitly: explicitly)
    }
  }
}

// MARK: - Private

@MainActor
private extension AppUpdater {
  static func presentError() {
    let alert = NSAlert()
    alert.messageText = Localized.Updater.updateFailedTitle
    alert.informativeText = Localized.Updater.updateFailedMessage
    alert.addButton(withTitle: Localized.Updater.checkVersionHistory)
    alert.addButton(withTitle: Localized.Updater.notNow)

    if alert.runModal() == .alertFirstButtonReturn {
      NSWorkspace.shared.safelyOpenURL(string: "https://github.com/MarkEdit-app/MarkEdit/releases")
    }
  }

  static func presentUpdate(newVersion: AppVersion, explicitly: Bool) {
    guard let currentVersion = Bundle.main.shortVersionString else {
      return Logger.assertFail("Invalid current version string")
    }

    // Check if the new version was skipped for implicit updates
    guard explicitly || !AppPreferences.Updater.skippedVersions.contains(newVersion.name) else {
      return
    }

    // Check if the version is different and wasn't released to MAS
    guard newVersion.name != currentVersion && !newVersion.releasedToMAS else {
      return {
        guard explicitly else {
          return
        }

        let alert = NSAlert()
        alert.messageText = Localized.Updater.upToDateTitle
        alert.informativeText = String(format: Localized.Updater.upToDateMessage, currentVersion)
        alert.runModal()
      }()
    }

    let alert = NSAlert()
    alert.messageText = String(format: Localized.Updater.newVersionAvailable, newVersion.name)
    alert.markdownBody = newVersion.body
    alert.addButton(withTitle: Localized.Updater.learnMore)

    if explicitly {
      alert.addButton(withTitle: Localized.Updater.notNow)
    } else {
      alert.addButton(withTitle: Localized.Updater.remindMeLater)
      alert.addButton(withTitle: Localized.Updater.skipThisVersion)
    }

    switch alert.runModal() {
    case .alertFirstButtonReturn: // Learn More
      NSWorkspace.shared.safelyOpenURL(string: newVersion.htmlUrl)
    case .alertThirdButtonReturn: // Skip This Version
      AppPreferences.Updater.skippedVersions.insert(newVersion.name)
    default:
      break
    }
  }
}
