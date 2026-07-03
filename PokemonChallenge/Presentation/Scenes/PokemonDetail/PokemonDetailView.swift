import SwiftUI

struct PokemonDetailView: View {
    @StateObject private var viewModel: PokemonDetailViewModel

    init(viewModel: PokemonDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        rootView
            .onAppear {
                viewModel.loadDetail()
            }
    }

    @ViewBuilder
    private var rootView: some View {
        switch viewModel.state {
        case .loading:
            shimmerDetail
        case .loaded(let detail):
            detailContent(detail)
        case .empty:
            emptyView
        case .error:
            errorView
        }
    }

    @ViewBuilder
    private func detailContent(_ detail: PokemonDetail) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.isShowingCachedData {
                    offlineBanner
                }

                spriteSection(detail)

                typesSection(detail.types)

                infoGrid(detail)

                statsSection(detail.stats)

                abilitiesSection(detail.abilities)
            }
            .padding(.vertical, 16)
        }
    }

    private func spriteSection(_ detail: PokemonDetail) -> some View {
        VStack(spacing: 8) {
            CachedPokemonImage(id: detail.id, size: 160)
                .id(viewModel.loadId)

            Text("#\(String(format: "%03d", detail.id))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .accessibilityIdentifier("pokemon_detail_sprite")
    }

    private func typesSection(_ types: [PokemonType]) -> some View {
        HStack(spacing: 8) {
            ForEach(types, id: \.name) { type in
                Text(type.name.capitalized)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(typeColor(type.name))
                    .clipShape(Capsule())
            }
        }
        .accessibilityLabel("Types: \(types.map(\.name.capitalized).joined(separator: ", "))")
        .accessibilityIdentifier("pokemon_detail_types")
    }

    private func infoGrid(_ detail: PokemonDetail) -> some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 12) {
            StatItem(label: "Altura", value: "\(Double(detail.height) / 10.0) m")
            StatItem(label: "Peso", value: "\(Double(detail.weight) / 10.0) kg")
            StatItem(label: "Exp. Base", value: "\(detail.baseExperience)")
        }
        .padding(.horizontal, 16)
        .accessibilityIdentifier("pokemon_detail_info")
    }

    private func statsSection(_ stats: [PokemonStat]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Estadísticas Base")

            VStack(spacing: 8) {
                ForEach(stats, id: \.name) { stat in
                    HStack(spacing: 8) {
                        Text(statName(stat.name))
                            .font(.subheadline)
                            .frame(width: 90, alignment: .leading)
                            .lineLimit(1)

                        Text("\(stat.baseStat)")
                            .font(.subheadline.monospacedDigit())
                            .fontWeight(.medium)
                            .frame(width: 36, alignment: .trailing)

                        ProgressView(value: min(Double(stat.baseStat) / StatConstants.maxStatValue, 1.0))
                            .tint(statColor(stat.baseStat))
                            .animation(.easeOut(duration: AnimationConstants.statBarAnimationDuration), value: stat.baseStat)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(statName(stat.name)): \(stat.baseStat) de 255")
                }
            }
            .padding(.horizontal, 16)
        }
        .accessibilityIdentifier("pokemon_detail_stats")
    }

    private func abilitiesSection(_ abilities: [PokemonAbility]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Habilidades")

            VStack(spacing: 4) {
                ForEach(abilities, id: \.name) { ability in
                    HStack {
                        Text(ability.name.replacingOccurrences(of: "-", with: " ").capitalized)
                            .font(.subheadline)

                        if ability.isHidden {
                            Text("Oculta")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.secondary.opacity(0.15))
                                .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(ability.name.replacingOccurrences(of: "-", with: " "))\(ability.isHidden ? ", habilidad oculta" : "")")
                }
            }
        }
        .accessibilityIdentifier("pokemon_detail_abilities")
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
    }

    private var offlineBanner: some View {
        OfflineBanner()
    }

    private var shimmerDetail: some View {
        ScrollView {
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.gray.opacity(0.15))
                    .frame(width: 160, height: 160)
                    .shimmer()

                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.15))
                            .frame(width: 60, height: 24)
                    }
                }

                LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 48)
                    }
                }
                .padding(.horizontal, 16)

                VStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { _ in
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.15))
                                .frame(width: 90, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.15))
                                .frame(width: 36, height: 14)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.gray.opacity(0.15))
                                .frame(height: 14)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Sin Detalles",
            systemImage: "questionmark.square.dashed",
            description: Text("No se pudieron cargar los detalles.")
        )
    }

    private var errorView: some View {
        ContentUnavailableView(
            "Error de Conexión",
            systemImage: "wifi.slash",
            description: Text("Revisa tu conexión e inténtalo de nuevo.")
        )
        .overlay(alignment: .bottom) {
            Button("Reintentar") { viewModel.loadDetail() }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 48)
        }
    }

    private func statName(_ english: String) -> String {
        switch english {
        case "hp": return "HP"
        case "attack": return "Ataque"
        case "defense": return "Defensa"
        case "special-attack": return "Ataque Esp."
        case "special-defense": return "Defensa Esp."
        case "speed": return "Velocidad"
        default: return english.replacingOccurrences(of: "-", with: " ").capitalized
        }
    }

    private func typeColor(_ type: String) -> Color {
        let colors: [String: Color] = [
            "normal": Color(red: 168 / 255, green: 168 / 255, blue: 120 / 255),
            "fire": Color(red: 240 / 255, green: 128 / 255, blue: 48 / 255),
            "water": Color(red: 104 / 255, green: 144 / 255, blue: 240 / 255),
            "electric": Color(red: 248 / 255, green: 208 / 255, blue: 48 / 255),
            "grass": Color(red: 120 / 255, green: 200 / 255, blue: 80 / 255),
            "ice": Color(red: 152 / 255, green: 216 / 255, blue: 216 / 255),
            "fighting": Color(red: 192 / 255, green: 48 / 255, blue: 40 / 255),
            "poison": Color(red: 160 / 255, green: 64 / 255, blue: 160 / 255),
            "ground": Color(red: 224 / 255, green: 192 / 255, blue: 104 / 255),
            "flying": Color(red: 168 / 255, green: 144 / 255, blue: 240 / 255),
            "psychic": Color(red: 248 / 255, green: 88 / 255, blue: 136 / 255),
            "bug": Color(red: 168 / 255, green: 184 / 255, blue: 32 / 255),
            "rock": Color(red: 184 / 255, green: 160 / 255, blue: 56 / 255),
            "ghost": Color(red: 112 / 255, green: 88 / 255, blue: 152 / 255),
            "dragon": Color(red: 112 / 255, green: 56 / 255, blue: 248 / 255),
            "dark": Color(red: 112 / 255, green: 88 / 255, blue: 72 / 255),
            "steel": Color(red: 184 / 255, green: 184 / 255, blue: 208 / 255),
            "fairy": Color(red: 248 / 255, green: 144 / 255, blue: 184 / 255),
        ]
        return colors[type.lowercased()] ?? .gray
    }

    private func statColor(_ value: Int) -> Color {
        switch value {
        case 0..<50: return .red
        case 50..<90: return .orange
        case 90..<130: return .yellow
        default: return .green
        }
    }
}

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.monospacedDigit().weight(.semibold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}
