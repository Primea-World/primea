class Parallel {
  title: string;
  color: string;

  constructor(title: string, color: string) {
    this.title = title;
    this.color = color;
  }
}


class Augencore extends Parallel {
  constructor() {
    super('Augencore', "#FF7432");
  }
}
class Earthen extends Parallel {
  constructor() {
    super('Earthen', "#49BC31");
  }
}
class Kathari extends Parallel {
  constructor() {
    super('Kathari', "#1E90DD");
  }
}
class Marcolian extends Parallel {
  constructor() {
    super('Marcolian', "#E20A1A");
  }
}
class Shroud extends Parallel {
  constructor() {
    super('Shroud', "#6438C6");
  }
}
class Universal extends Parallel {
  constructor() {
    super('Universal', "#FFFFFFB3");
  }
}

abstract class Paragon {
  abstract parallel: Parallel;
  abstract name?: string;
  abstract description?: string;
  focalPoint: number = -100;

  static fromString(str: string): Paragon {
    switch (str) {
      case "jahn":
        return new Jahn();
      case "arak":
        return new Arak();
      case "gaffar":
        return new Gaffar();
      case "lemieux":
        return new Lemieux();
      case "catherineLapointe":
        return new CatherineLapointe();
      case "armouredDivisionHQ":
        return new ArmouredDivisionHQ();
      case "gnaeusValerusAlpha":
        return new GnaeusValerusAlpha();
      case "scipiusMagnusAlpha":
        return new ScipiusMagnusAlpha();
      case "aetio":
        return new Aetio();
      case "juggernautWorkshop":
        return new JuggernautWorkshop();
      case "brand":
        return new Brand();
      case "niamh":
        return new Niamh();
      case "newDawn":
        return new NewDawn();
      case "shoshanna":
        return new Shoshanna();
      case "nehemiah":
        return new Nehemiah();
      default:
        return new Unknown();
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

const AUGENCORE = new Augencore();
const EARTHEN = new Earthen();
const KATHARI = new Kathari();
const MARCOLIAN = new Marcolian();
const SHROUD = new Shroud();
const UNIVERSAL = new Universal();

class Unknown extends Paragon {
  parallel = UNIVERSAL;
  name = "Unknown";
  description?: string;
}

class Arak extends Paragon {
  parallel = AUGENCORE;
  name = "Arak";
  description = "Combat Overseer";
  focalPoint: number = -65;
}
class Jahn extends Paragon {
  parallel = AUGENCORE;
  name = "Jahn";
  description = "Chief Engineer";
  focalPoint: number = -70;

}
class JuggernautWorkshop extends Paragon {
  parallel = AUGENCORE;
  name = "Juggernaut Workshop";
  description?: string;
  focalPoint: number = -190;
}

class Gaffar extends Paragon {
  parallel = EARTHEN;
  name = "Gaffar";
  description = "Arbiter of Earth";
}
class Nehemiah extends Paragon {
  parallel = EARTHEN;
  name = "Nehemiah";
  description = "Defender of Earth";
}
class Shoshanna extends Paragon {
  parallel = EARTHEN;
  name = "Shoshanna";
  description = "Rebuilder of Earth";
}

class Aetio extends Paragon {
  parallel = KATHARI;
  name = "Aetio";
  description = "Exalted Hydrolist";
  focalPoint: number = -50;
}
class GnaeusValerusAlpha extends Paragon {
  parallel = KATHARI;
  name = "Gnaeus Valerus Alpha";
  description?: string;
  focalPoint: number = -285;
}
class ScipiusMagnusAlpha extends Paragon {
  parallel = KATHARI;
  name = "Scipius Magnus Alpha";
  description?: string;
  focalPoint: number = -20;
}

class ArmouredDivisionHQ extends Paragon {
  parallel = MARCOLIAN;
  name = "Armoured Division HQ";
  description?: string;
  focalPoint: number = -133;
}
class CatherineLapointe extends Paragon {
  parallel = MARCOLIAN;
  name = "Catherine Lapointe";
  description = "Mad General";
  focalPoint: number = -25;
}
class Lemieux extends Paragon {
  parallel = MARCOLIAN;
  name = "Lemieux";
  description = "Master Commando";
  focalPoint: number = -155;
}

class Brand extends Paragon {
  parallel = SHROUD;
  name = "Brand";
  description = "Eternal Steward";
  focalPoint: number = -45;
}
class NewDawn extends Paragon {
  parallel = SHROUD;
  name = "New Dawn";
  description?: string;
  focalPoint: number = -165;
}
class Niamh extends Paragon {
  parallel = SHROUD;
  name = "Niamh";
  description = "Wielder of Faith";
}

export {
  Parallel,
  AUGENCORE,
  EARTHEN,
  KATHARI,
  MARCOLIAN,
  SHROUD,
  UNIVERSAL,
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