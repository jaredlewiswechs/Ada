import Foundation
import EventKit
import AVFoundation

/// Centralized permissions manager.
/// Ensures clear consent for each capability before Ada uses it.
@MainActor
@Observable
final class PermissionsManager {
    var calendarGranted = false
    var remindersGranted = false
    var cameraGranted = false

    func checkAll() async {
        let ekStore = EKEventStore()
        calendarGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        remindersGranted = EKEventStore.authorizationStatus(for: .reminder) == .fullAccess
        cameraGranted = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    func requestCalendar() async -> Bool {
        let result = await CalendarService.shared.requestAccess()
        calendarGranted = result
        return result
    }

    func requestReminders() async -> Bool {
        let result = await ReminderService.shared.requestAccess()
        remindersGranted = result
        return result
    }

    func requestCamera() async -> Bool {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        cameraGranted = granted
        return granted
    }
}
