import SwiftUI

struct PokemonRowView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 6) {
            CachedPokemonImage(id: pokemon.id, size: 64)

            Text(pokemon.name.capitalized)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(pokemon.name.capitalized), Pokémon")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("pokemon_row_\(pokemon.id)")
    }
}
