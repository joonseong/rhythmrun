import SwiftUI

struct ResultsView: View {
    let session: RunSession

    var body: some View {
        ZStack {
            Color.rrVoid.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("🎉 완주!")
                    .font(.rrDisplay)
                    .foregroundColor(.rrWhite)

                Text("등급: \(session.grade.rawValue)")
                    .font(.rrTitle)
                    .foregroundColor(.rrNeonGreen)

                VStack(alignment: .leading, spacing: 12) {
                    ResultRow(label: "평균 BPM", value: "\(session.avgBPM)")
                    ResultRow(label: "최고 콤보", value: "\(session.maxCombo)")
                    ResultRow(label: "총점", value: "\(session.totalScore)")
                }
                .padding(20)
                .background(Color.rrDeepTeal)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.rrCardBorder, lineWidth: 1))

                Spacer()
            }
            .padding(24)
        }
    }
}

private struct ResultRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label).foregroundColor(.rrMuted).font(.rrBody)
            Spacer()
            Text(value).foregroundColor(.rrWhite).font(.rrBody)
        }
    }
}
