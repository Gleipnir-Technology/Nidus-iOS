import SwiftUI

enum AudioTagCategory: String, CaseIterable {
	case priority
	case landCategory
	case trapSite
	case arbovirus
	case mosquitoStage
	case mosquitoSex
	case mosquitoTrap
	case mosquitoTrapStatus
	case habitat
	case species
	case genus
	case waterOrigin
	case waterUse
	case product
	case contactInfo
	case dataType
}

struct AudioTagIdentifier {
	let category: AudioTagCategory
	let text: String

	static func parseTags(_ transcription: String) -> [AudioTagMatch] {
		var results: [AudioTagMatch] = []
		for identifier in AUDIO_TAG_IDENTIFIERS {
			let ranges = transcription.ranges(of: identifier.text)
			for range in ranges {
				results.append(
					AudioTagMatch(
						category: identifier.category,
						range: range,
						text: identifier.text
					)
				)
			}
		}
		return results
	}
}

let AUDIO_TAG_IDENTIFIERS: [AudioTagIdentifier] = [
	AudioTagIdentifier(category: .priority, text: "low"),
	AudioTagIdentifier(category: .priority, text: "none"),
	AudioTagIdentifier(category: .priority, text: "medium"),
	AudioTagIdentifier(category: .priority, text: "high"),

	AudioTagIdentifier(category: .landCategory, text: "residential"),
	AudioTagIdentifier(category: .landCategory, text: "commercial"),
	AudioTagIdentifier(category: .landCategory, text: "agriculture"),
	AudioTagIdentifier(category: .landCategory, text: "municipal"),
	AudioTagIdentifier(category: .landCategory, text: "rural"),
	AudioTagIdentifier(category: .landCategory, text: "natural"),

	AudioTagIdentifier(category: .trapSite, text: "fixed trapping"),
	AudioTagIdentifier(category: .trapSite, text: "response trapping"),
	AudioTagIdentifier(category: .trapSite, text: "service request"),
	AudioTagIdentifier(category: .trapSite, text: "project trapping"),

	AudioTagIdentifier(category: .arbovirus, text: "west nile virus"),
	AudioTagIdentifier(category: .arbovirus, text: "saint luis encephilitus"),
	AudioTagIdentifier(category: .arbovirus, text: "western equine encephilitus"),
	AudioTagIdentifier(category: .arbovirus, text: "dengue virus"),
	AudioTagIdentifier(category: .arbovirus, text: "zika virus"),
	AudioTagIdentifier(category: .arbovirus, text: "chickengunya"),

	AudioTagIdentifier(category: .mosquitoStage, text: "egg"),
	AudioTagIdentifier(category: .mosquitoStage, text: "first instar"),
	AudioTagIdentifier(category: .mosquitoStage, text: "second instar"),
	AudioTagIdentifier(category: .mosquitoStage, text: "third instar"),
	AudioTagIdentifier(category: .mosquitoStage, text: "fourth instar"),
	AudioTagIdentifier(category: .mosquitoStage, text: "pupa"),
	AudioTagIdentifier(category: .mosquitoStage, text: "pupae"),
	AudioTagIdentifier(category: .mosquitoStage, text: "adult"),

	AudioTagIdentifier(category: .mosquitoSex, text: "male"),
	AudioTagIdentifier(category: .mosquitoSex, text: "female"),

	AudioTagIdentifier(category: .mosquitoTrap, text: "gravid trap"),
	AudioTagIdentifier(category: .mosquitoTrap, text: "bg sentinel"),
	AudioTagIdentifier(category: .mosquitoTrap, text: "co2"),

	AudioTagIdentifier(category: .mosquitoTrapStatus, text: "set"),
	AudioTagIdentifier(category: .mosquitoTrapStatus, text: "collected"),
	AudioTagIdentifier(category: .mosquitoTrapStatus, text: "damaged"),
	AudioTagIdentifier(category: .mosquitoTrapStatus, text: "missing"),

	AudioTagIdentifier(category: .habitat, text: "orchard"),
	AudioTagIdentifier(category: .habitat, text: "row crops"),
	AudioTagIdentifier(category: .habitat, text: "vine crops"),
	AudioTagIdentifier(category: .habitat, text: "agricultural grass"),
	AudioTagIdentifier(category: .habitat, text: "agricultural grasses"),
	AudioTagIdentifier(category: .habitat, text: "agricultural grain"),
	AudioTagIdentifier(category: .habitat, text: "agricultural grains"),
	AudioTagIdentifier(category: .habitat, text: "pasture"),
	AudioTagIdentifier(category: .habitat, text: "irrigation standpipe"),
	AudioTagIdentifier(category: .habitat, text: "ditch"),
	AudioTagIdentifier(category: .habitat, text: "pond"),
	AudioTagIdentifier(category: .habitat, text: "sump"),
	AudioTagIdentifier(category: .habitat, text: "drain"),
	AudioTagIdentifier(category: .habitat, text: "dairy lagoon"),
	AudioTagIdentifier(category: .habitat, text: "wastewater treatment"),
	AudioTagIdentifier(category: .habitat, text: "trough"),
	AudioTagIdentifier(category: .habitat, text: "depression"),
	AudioTagIdentifier(category: .habitat, text: "gutter"),
	AudioTagIdentifier(category: .habitat, text: "rain gutter"),
	AudioTagIdentifier(category: .habitat, text: "culvert"),
	AudioTagIdentifier(category: .habitat, text: "utility"),
	AudioTagIdentifier(category: .habitat, text: "catch basin"),
	AudioTagIdentifier(category: .habitat, text: "stream"),
	AudioTagIdentifier(category: .habitat, text: "creek"),
	AudioTagIdentifier(category: .habitat, text: "slough"),
	AudioTagIdentifier(category: .habitat, text: "river"),
	AudioTagIdentifier(category: .habitat, text: "marsh"),
	AudioTagIdentifier(category: .habitat, text: "wetland"),
	AudioTagIdentifier(category: .habitat, text: "containers"),
	AudioTagIdentifier(category: .habitat, text: "watering bowl"),
	AudioTagIdentifier(category: .habitat, text: "plant saucer"),
	AudioTagIdentifier(category: .habitat, text: "yard drain"),
	AudioTagIdentifier(category: .habitat, text: "plant axil"),
	AudioTagIdentifier(category: .habitat, text: "tree hole"),
	AudioTagIdentifier(category: .habitat, text: "fountain"),
	AudioTagIdentifier(category: .habitat, text: "water feature"),
	AudioTagIdentifier(category: .habitat, text: "bird bath"),
	AudioTagIdentifier(category: .habitat, text: "miscellaneos water accumulation"),
	AudioTagIdentifier(category: .habitat, text: "tarp"),
	AudioTagIdentifier(category: .habitat, text: "cover"),
	AudioTagIdentifier(category: .habitat, text: "swimming pool"),
	AudioTagIdentifier(category: .habitat, text: "aboveground pool"),
	AudioTagIdentifier(category: .habitat, text: "kid pool"),
	AudioTagIdentifier(category: .habitat, text: "pool"),
	AudioTagIdentifier(category: .habitat, text: "hot tub"),
	AudioTagIdentifier(category: .habitat, text: "appliance"),
	AudioTagIdentifier(category: .habitat, text: "tires"),
	AudioTagIdentifier(category: .habitat, text: "flooded structure"),
	AudioTagIdentifier(category: .habitat, text: "low point"),

	AudioTagIdentifier(category: .species, text: "ae aegypti"),
	AudioTagIdentifier(category: .species, text: "ae albopictus"),
	AudioTagIdentifier(category: .species, text: "ae melanimon"),
	AudioTagIdentifier(category: .species, text: "ae nigromaculis"),
	AudioTagIdentifier(category: .species, text: "ae sierrensis"),
	AudioTagIdentifier(category: .species, text: "ae vexans"),
	AudioTagIdentifier(category: .species, text: "ae franciscanus"),
	AudioTagIdentifier(category: .species, text: "ae freeborni"),
	AudioTagIdentifier(category: .species, text: "ae punctipennis"),
	AudioTagIdentifier(category: .species, text: "cs incidens"),
	AudioTagIdentifier(category: .species, text: "cs inornata"),
	AudioTagIdentifier(category: .species, text: "cs particeps"),
	AudioTagIdentifier(category: .species, text: "cx erythrothorax"),
	AudioTagIdentifier(category: .species, text: "cx quinquefasciatus"),
	AudioTagIdentifier(category: .species, text: "cx restuans"),
	AudioTagIdentifier(category: .species, text: "cx stigmatosoma"),
	AudioTagIdentifier(category: .species, text: "cx tarsalis"),
	AudioTagIdentifier(category: .species, text: "cx thriambus"),

	AudioTagIdentifier(category: .genus, text: "aedes"),
	AudioTagIdentifier(category: .genus, text: "culex"),
	AudioTagIdentifier(category: .genus, text: "anopheles"),
	AudioTagIdentifier(category: .genus, text: "culiseta"),

	AudioTagIdentifier(category: .waterOrigin, text: "flood irrigation"),
	AudioTagIdentifier(category: .waterOrigin, text: "furrow irrigation"),
	AudioTagIdentifier(category: .waterOrigin, text: "drip irrigation"),
	AudioTagIdentifier(category: .waterOrigin, text: "sprinkler irrigation"),
	AudioTagIdentifier(category: .waterOrigin, text: "wastewater irrigation"),
	AudioTagIdentifier(category: .waterOrigin, text: "irrigation runoff"),
	AudioTagIdentifier(category: .waterOrigin, text: "stormwater"),
	AudioTagIdentifier(category: .waterOrigin, text: "municipal runoff"),
	AudioTagIdentifier(category: .waterOrigin, text: "industrial runoff"),
	AudioTagIdentifier(category: .waterOrigin, text: "rainwater accumulation"),
	AudioTagIdentifier(category: .waterOrigin, text: "leak"),
	AudioTagIdentifier(category: .waterOrigin, text: "seepage"),
	AudioTagIdentifier(category: .waterOrigin, text: "stored water"),
	AudioTagIdentifier(category: .waterOrigin, text: "wastewater system"),
	AudioTagIdentifier(category: .waterOrigin, text: "permanent natural water"),
	AudioTagIdentifier(category: .waterOrigin, text: "temporary natural water"),
	AudioTagIdentifier(category: .waterOrigin, text: "recreational water"),
	AudioTagIdentifier(category: .waterOrigin, text: "ornamental water"),
	AudioTagIdentifier(category: .waterOrigin, text: "water conveyance"),
	AudioTagIdentifier(category: .waterOrigin, text: "agricultural"),
	AudioTagIdentifier(category: .waterOrigin, text: "commercial"),
	AudioTagIdentifier(category: .waterOrigin, text: "mixed use"),
	AudioTagIdentifier(category: .waterOrigin, text: "public domain"),
	AudioTagIdentifier(category: .waterOrigin, text: "residential"),
	AudioTagIdentifier(category: .waterOrigin, text: "conveyance"),
	AudioTagIdentifier(category: .waterOrigin, text: "natural"),

	AudioTagIdentifier(category: .product, text: "agnique mmf"),
	AudioTagIdentifier(category: .product, text: "a.l.l. concentrate sr-20"),
	AudioTagIdentifier(category: .product, text: "altosid sr-5%"),
	AudioTagIdentifier(category: .product, text: "altosand a.l.l sr-5"),
	AudioTagIdentifier(category: .product, text: "altosid briquet xr"),
	AudioTagIdentifier(category: .product, text: "altosid p35"),
	AudioTagIdentifier(category: .product, text: "altosid sbg 2"),
	AudioTagIdentifier(category: .product, text: "altosid wsp"),
	AudioTagIdentifier(category: .product, text: "altosid xrg"),
	AudioTagIdentifier(category: .product, text: "altosid xrg ultra"),
	AudioTagIdentifier(category: .product, text: "bva-2"),
	AudioTagIdentifier(category: .product, text: "censor"),
	AudioTagIdentifier(category: .product, text: "cocobear"),
	AudioTagIdentifier(category: .product, text: "duplex g"),
	AudioTagIdentifier(category: .product, text: "evergreen pyronyl 525"),
	AudioTagIdentifier(category: .product, text: "fourstar 180"),
	AudioTagIdentifier(category: .product, text: "fyfanon ulv"),
	AudioTagIdentifier(category: .product, text: "merus 3.0"),
	AudioTagIdentifier(category: .product, text: "metalarv xrp wsp"),
	AudioTagIdentifier(category: .product, text: "natular 2ec"),
	AudioTagIdentifier(category: .product, text: "natular dt"),
	AudioTagIdentifier(category: .product, text: "natular g30"),
	AudioTagIdentifier(category: .product, text: "natular g30 wsp"),
	AudioTagIdentifier(category: .product, text: "natular sc"),
	AudioTagIdentifier(category: .product, text: "spheratax sph 50 g"),
	AudioTagIdentifier(category: .product, text: "sumilarv wsp 0.5g"),
	AudioTagIdentifier(category: .product, text: "vectobac 12as"),
	AudioTagIdentifier(category: .product, text: "vectobac g"),
	AudioTagIdentifier(category: .product, text: "vectobac gr"),
	AudioTagIdentifier(category: .product, text: "vectobac wdg"),
	AudioTagIdentifier(category: .product, text: "vectobac wsp"),
	AudioTagIdentifier(category: .product, text: "vectobac fg"),
	AudioTagIdentifier(category: .product, text: "zenivex e4"),

	AudioTagIdentifier(category: .contactInfo, text: "person name"),
	AudioTagIdentifier(category: .contactInfo, text: "company name"),
	AudioTagIdentifier(category: .contactInfo, text: "phone number"),
	AudioTagIdentifier(category: .contactInfo, text: "email address"),
	AudioTagIdentifier(category: .contactInfo, text: "postal address"),

	AudioTagIdentifier(category: .dataType, text: "measurement"),
	AudioTagIdentifier(category: .dataType, text: "area"),
	AudioTagIdentifier(category: .dataType, text: "volume"),
	AudioTagIdentifier(category: .dataType, text: "weight"),
	AudioTagIdentifier(category: .dataType, text: "count"),
	AudioTagIdentifier(category: .dataType, text: "percentage"),
	AudioTagIdentifier(category: .dataType, text: "rate"),
]

struct AudioTagMatch: Hashable {
	let category: AudioTagCategory
	let range: Range<String.Index>
	let text: String

	// Color palette generated from https://coolors.co/c4a69d-98a886-465c69-363457-735290
	func color() -> Color {
		switch category {
		case .landCategory, .habitat:
			return Color.cyan
		case .arbovirus:
			return Color.purple
		case .genus, .mosquitoSex, .mosquitoStage, .mosquitoTrap, .mosquitoTrapStatus,
			.species:
			return Color.red
		case .waterOrigin, .waterUse:
			return Color.blue
		case .product:
			return Color.green
		case .contactInfo, .dataType, .priority, .trapSite:
			return Color.gray
		}
	}

	init(category: AudioTagCategory, text: String) {
		self.category = category
		self.range = text.startIndex..<text.endIndex
		self.text = text
	}

	init(category: AudioTagCategory, range: Range<String.Index>, text: String) {
		self.category = category
		self.range = range
		self.text = text
	}

	struct Preview {
		static let tags: [AudioTagMatch] = [
			AudioTagMatch(category: .priority, text: "low"),
			AudioTagMatch(category: .landCategory, text: "commercial"),
			AudioTagMatch(category: .trapSite, text: "service request"),
			AudioTagMatch(category: .arbovirus, text: "dengue virus"),
			AudioTagMatch(category: .mosquitoStage, text: "adult"),
			AudioTagMatch(category: .mosquitoTrap, text: "co2"),
			AudioTagMatch(category: .habitat, text: "vine crops"),
		]
	}
}
