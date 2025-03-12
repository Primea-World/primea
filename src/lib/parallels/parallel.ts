abstract class Parallel {
  static title: string;
  static color: string;
}


class Augencore extends Parallel {
  static title = "Augencore";
  static color = "#FF7432";
}
class Earthen extends Parallel {
  static title = "Earthen";
  static color = "#49BC31";
}
class Kathari extends Parallel {
  static title = "Kathari";
  static color = "#1E90DD";
}
class Marcolian extends Parallel {
  static title = "Marcolian";
  static color = "#E20A1A";
}
class Shroud extends Parallel {
  static title = "Shroud";
  static color = "#6438C6";
}
class Universal extends Parallel {
  static title = "Universal";
  static color = "#FFFFFFB3";
}

abstract class Paragon {
  static parallel: typeof Parallel;
  static name: string;
  static description?: string;
  static focalPoint: number = -100;

  static get camelCaseName(): string {
    return this.name?.replaceAll(' ', '') ?? "";
  }

  static fromString(str: string): typeof Paragon {
    switch (str) {
      case "Jahn":
        return Jahn;
      case "Arak":
        return Arak;
      case "Gaffar":
        return Gaffar;
      case "Lemieux":
        return Lemieux;
      case "CatherineLapointe":
        return CatherineLapointe;
      case "ArmouredDivisionHQ":
        return ArmouredDivisionHQ;
      case "GnaeusValerusAlpha":
        return GnaeusValerusAlpha;
      case "ScipiusMagnusAlpha":
        return ScipiusMagnusAlpha;
      case "Aetio":
        return Aetio;
      case "JuggernautWorkshop":
        return JuggernautWorkshop;
      case "Brand":
        return Brand;
      case "Niamh":
        return Niamh;
      case "NewDawn":
        return NewDawn;
      case "Shoshanna":
        return Shoshanna;
      case "Nehemiah":
        return Nehemiah;
      default:
        return Unknown;
    }
  }

  static fromCardID(cardID: number): Paragon {
    switch (cardID) {
      case 9:
        return new Jahn();
      case 21:
        return new Arak();
      case 62:
        return new Gaffar();
      case 171:
        return new Lemieux();
      case 197:
        return new CatherineLapointe();
      case 277:
        return new ArmouredDivisionHQ();
      case 371:
        return new GnaeusValerusAlpha();
      case 373:
        return new ScipiusMagnusAlpha();
      case 375:
        return new Aetio();
      case 376:
        return new JuggernautWorkshop();
      case 378:
        return new Brand();
      case 379:
        return new Niamh();
      case 380:
        return new NewDawn();
      case 389:
        return new Shoshanna();
      case 390:
        return new Nehemiah();
      default:
        return new Unknown();
    }
  }
}

class Unknown extends Paragon {
  static parallel = Universal;
  static name = "Unknown";
  static description?: string;
}

class Arak extends Paragon {
  static parallel = Augencore;
  static name = "Arak";
  static description = "Combat Overseer";
  static focalPoint: number = -65;
}
class Jahn extends Paragon {
  static parallel = Augencore;
  static name = "Jahn";
  static description = "Chief Engineer";
  static focalPoint: number = -70;

}
class JuggernautWorkshop extends Paragon {
  static parallel = Augencore;
  static name = "Juggernaut Workshop";
  static description?: string;
  static focalPoint: number = -190;
}

class Gaffar extends Paragon {
  static parallel = Earthen;
  static name = "Gaffar";
  static description = "Arbiter of Earth";
}
class Nehemiah extends Paragon {
  static parallel = Earthen;
  static name = "Nehemiah";
  static description = "Defender of Earth";
}
class Shoshanna extends Paragon {
  static parallel = Earthen;
  static name = "Shoshanna";
  static description = "Rebuilder of Earth";
}

class Aetio extends Paragon {
  static parallel = Kathari;
  static name = "Aetio";
  static description = "Exalted Hydrolist";
  static focalPoint: number = -50;
}
class GnaeusValerusAlpha extends Paragon {
  static parallel = Kathari;
  static name = "Gnaeus Valerus Alpha";
  static description?: string;
  static focalPoint: number = -285;
}
class ScipiusMagnusAlpha extends Paragon {
  static parallel = Kathari;
  static name = "Scipius Magnus Alpha";
  static description?: string;
  static focalPoint: number = -20;
}

class ArmouredDivisionHQ extends Paragon {
  static parallel = Marcolian;
  static name = "Armoured Division HQ";
  static description?: string;
  static focalPoint: number = -133;
}
class CatherineLapointe extends Paragon {
  static parallel = Marcolian;
  static name = "Catherine Lapointe";
  static description = "Mad General";
  static focalPoint: number = -25;
}
class Lemieux extends Paragon {
  static parallel = Marcolian;
  static name = "Lemieux";
  static description = "Master Commando";
  static focalPoint: number = -155;
}

class Brand extends Paragon {
  static parallel = Shroud;
  static name = "Brand";
  static description = "Eternal Steward";
  static focalPoint: number = -45;
}
class NewDawn extends Paragon {
  static parallel = Shroud;
  static name = "New Dawn";
  static description?: string;
  static focalPoint: number = -165;
}
class Niamh extends Paragon {
  static parallel = Shroud;
  static name = "Niamh";
  static description = "Wielder of Faith";
}

export {
  Parallel,
  Augencore,
  Earthen,
  Kathari,
  Marcolian,
  Shroud,
  Universal,
  Paragon,
  Unknown,
  Arak,
  Jahn,
  JuggernautWorkshop,
  Gaffar,
  Nehemiah,
  Shoshanna,
  Aetio,
  GnaeusValerusAlpha,
  ScipiusMagnusAlpha,
  ArmouredDivisionHQ,
  CatherineLapointe,
  Lemieux,
  Brand,
  NewDawn,
  Niamh,
};