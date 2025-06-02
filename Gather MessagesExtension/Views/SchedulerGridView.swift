//
//  SchedulerGridView.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//


import SwiftUI

struct SchedulerGridView: View {
    let startDate: Date
    let endDate: Date
    let hours: [String] = (8...20).map { "\($0):00" }  // 8 AM to 8 PM
    @Binding var availability: [String: [String: Bool]]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                ForEach(dateRange(), id: \.self) { date in
                    VStack {
                        Text(formatted(date))
                            .font(.caption)
                            .padding(.bottom, 4)
                        ForEach(hours, id: \.self) { hour in
                            let key = formatted(date)
                            let isAvailable = availability[key]?[hour] ?? false
                            Rectangle()
                                .fill(isAvailable ? Color.purple.opacity(0.8) : Color.gray.opacity(0.2))
                                .frame(width: 40, height: 30)
                                .cornerRadius(6)
                                .onTapGesture {
                                    toggleAvailability(for: key, hour: hour)
                                }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func toggleAvailability(for date: String, hour: String) {
        if availability[date] == nil {
            availability[date] = [:]
        }
        availability[date]?[hour] = !(availability[date]?[hour] ?? false)
    }

    private func dateRange() -> [Date] {
        var dates: [Date] = []
        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}
