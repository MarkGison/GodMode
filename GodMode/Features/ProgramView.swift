import SwiftUI
import GodModeCore

struct ProgramView: View {
    let program: TrainingProgram

    var body: some View {
        Page {
            Text(program.name).font(DesignTokens.TypeStyle.title)
            ForEach(program.days) { day in
                NavigationLink {
                    WorkoutOverviewView(program: program, day: day)
                } label: {
                    Panel {
                        Text(day.name).font(DesignTokens.TypeStyle.title)
                        Text(day.focus).foregroundStyle(DesignTokens.Color.textSecondary)
                        Label("\(day.exerciseCount) exercises", systemImage: "arrow.right")
                            .foregroundStyle(DesignTokens.Color.energy)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("program.\(day.id)")
            }
            Text(program.reviewNotice)
                .font(DesignTokens.TypeStyle.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .navigationTitle("Quests")
    }
}

private struct WorkoutOverviewView: View {
    let program: TrainingProgram
    let day: WorkoutDay

    var body: some View {
        Page {
            Text(day.focus).font(DesignTokens.TypeStyle.title)
            ForEach(day.blocks) { block in
                Panel {
                    if block.rounds > 1 {
                        Text("\(block.rounds) rounds · \(block.roundRestSeconds)s rest after each round")
                            .font(DesignTokens.TypeStyle.section)
                    }
                    ForEach(block.prescriptions) { prescription in
                        if let exercise = program.exercise(id: prescription.exerciseID) {
                            VStack(alignment: .leading, spacing: DesignTokens.Space.inline) {
                                Text(exercise.name).font(DesignTokens.TypeStyle.section)
                                PrescriptionSummary(prescription: prescription)
                                Text(exercise.safetyNote)
                                    .font(DesignTokens.TypeStyle.caption)
                                    .foregroundStyle(DesignTokens.Color.textSecondary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityIdentifier("exercise.\(prescription.id)")
                        }
                    }
                }
            }
            Text("Workout logging is in development. This program overview does not record a session.")
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .navigationTitle(day.name)
    }
}

private struct PrescriptionSummary: View {
    let prescription: ExercisePrescription

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Space.inline) {
            switch prescription.target {
            case .reps:
                if let lower = prescription.minimumReps, let upper = prescription.maximumReps {
                    Text("\(prescription.sets) sets · \(lower)–\(upper) reps")
                }
            case .amrap:
                Text("\(prescription.sets) sets · AMRAP with safe technique")
            case .timed:
                if let seconds = prescription.durationSeconds {
                    Text("\(prescription.sets) sets · \(seconds) seconds")
                }
            }
            if prescription.sideTracking == .eachSide { Text("Track each side separately") }
            if let tempo = prescription.tempo { Text("Tempo \(tempo.notation)") }
            Text("Rest \(prescription.restSeconds) seconds")
        }
        .font(DesignTokens.TypeStyle.body)
    }
}
