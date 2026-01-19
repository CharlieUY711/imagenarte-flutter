// Tipos de acciones MVP para Imagen@rte
// Solo las operaciones canónicas de privacidad y preparación

export interface ActionsStateMVP {
  pixelate: {
    enabled: boolean;
    intensity: number; // 1-10
  };
  blur: {
    enabled: boolean;
    intensity: number; // 1-10
  };
  crop: {
    enabled: boolean;
    ratio: '1:1' | '16:9' | '4:3' | '9:16';
  };
  removeBackground: {
    enabled: false; // Siempre false (próximamente)
  };
}

export const initialActionsMVP: ActionsStateMVP = {
  pixelate: {
    enabled: false,
    intensity: 5,
  },
  blur: {
    enabled: false,
    intensity: 5,
  },
  crop: {
    enabled: false,
    ratio: '1:1',
  },
  removeBackground: {
    enabled: false,
  },
};
