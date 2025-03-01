export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  public: {
    Tables: {
      analytics: {
        Row: {
          created_at: string
          data: Json | null
          event: string
          user_id: string
        }
        Insert: {
          created_at?: string
          data?: Json | null
          event: string
          user_id?: string
        }
        Update: {
          created_at?: string
          data?: Json | null
          event?: string
          user_id?: string
        }
        Relationships: []
      }
      bond_members: {
        Row: {
          bond: number
          date_initiated: string
          date_joined: string | null
          sponsor: string | null
          status: Database["public"]["Enums"]["bond_invitation_status"]
          user_id: string
        }
        Insert: {
          bond: number
          date_initiated?: string
          date_joined?: string | null
          sponsor?: string | null
          status: Database["public"]["Enums"]["bond_invitation_status"]
          user_id?: string
        }
        Update: {
          bond?: number
          date_initiated?: string
          date_joined?: string | null
          sponsor?: string | null
          status?: Database["public"]["Enums"]["bond_invitation_status"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "bond_members_bond_fkey"
            columns: ["bond"]
            isOneToOne: false
            referencedRelation: "bonds"
            referencedColumns: ["id"]
          },
        ]
      }
      bonds: {
        Row: {
          created_at: string
          created_by: string
          id: number
          name: string
          tag: string
        }
        Insert: {
          created_at?: string
          created_by?: string
          id?: number
          name: string
          tag: string
        }
        Update: {
          created_at?: string
          created_by?: string
          id?: number
          name?: string
          tag?: string
        }
        Relationships: []
      }
      card_functions: {
        Row: {
          attack: number
          basename: string
          card_type: Database["public"]["Enums"]["card_type"]
          cost: number
          expansion: Database["public"]["Enums"]["expansion"]
          flavour_text: string
          function_text: string
          health: number
          id: number
          parallel: Database["public"]["Enums"]["parallel"]
          passive_ability: string | null
          rarity: Database["public"]["Enums"]["card_rarity"]
          subtype: Database["public"]["Enums"]["card_subtype"] | null
          title: string
        }
        Insert: {
          attack: number
          basename: string
          card_type: Database["public"]["Enums"]["card_type"]
          cost: number
          expansion: Database["public"]["Enums"]["expansion"]
          flavour_text: string
          function_text: string
          health: number
          id?: number
          parallel: Database["public"]["Enums"]["parallel"]
          passive_ability?: string | null
          rarity: Database["public"]["Enums"]["card_rarity"]
          subtype?: Database["public"]["Enums"]["card_subtype"] | null
          title: string
        }
        Update: {
          attack?: number
          basename?: string
          card_type?: Database["public"]["Enums"]["card_type"]
          cost?: number
          expansion?: Database["public"]["Enums"]["expansion"]
          flavour_text?: string
          function_text?: string
          health?: number
          id?: number
          parallel?: Database["public"]["Enums"]["parallel"]
          passive_ability?: string | null
          rarity?: Database["public"]["Enums"]["card_rarity"]
          subtype?: Database["public"]["Enums"]["card_subtype"] | null
          title?: string
        }
        Relationships: []
      }
      decks: {
        Row: {
          cards: number[]
          created_at: string
          hidden: boolean
          id: string
          name: string
          owner: string
          updated_at: string | null
        }
        Insert: {
          cards: number[]
          created_at?: string
          hidden?: boolean
          id?: string
          name: string
          owner?: string
          updated_at?: string | null
        }
        Update: {
          cards?: number[]
          created_at?: string
          hidden?: boolean
          id?: string
          name?: string
          owner?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      errors: {
        Row: {
          context: string | null
          created_at: string
          error: string | null
          library: string | null
          stack: string | null
          user_id: string
        }
        Insert: {
          context?: string | null
          created_at?: string
          error?: string | null
          library?: string | null
          stack?: string | null
          user_id?: string
        }
        Update: {
          context?: string | null
          created_at?: string
          error?: string | null
          library?: string | null
          stack?: string | null
          user_id?: string
        }
        Relationships: []
      }
      games: {
        Row: {
          created_at: string
          deck_id: string | null
          game_time: string
          id: string
          mmr_delta: number | null
          notes: string | null
          opponent_paragon: Database["public"]["Enums"]["paragon"]
          opponent_rank: Database["public"]["Enums"]["player_rank"] | null
          opponent_username: string | null
          paragon: Database["public"]["Enums"]["paragon"]
          player_one: boolean
          prime_estimate: number | null
          result: Database["public"]["Enums"]["game_result"]
          season: number
          updated_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          deck_id?: string | null
          game_time?: string
          id?: string
          mmr_delta?: number | null
          notes?: string | null
          opponent_paragon: Database["public"]["Enums"]["paragon"]
          opponent_rank?: Database["public"]["Enums"]["player_rank"] | null
          opponent_username?: string | null
          paragon: Database["public"]["Enums"]["paragon"]
          player_one: boolean
          prime_estimate?: number | null
          result: Database["public"]["Enums"]["game_result"]
          season: number
          updated_at?: string | null
          user_id?: string
        }
        Update: {
          created_at?: string
          deck_id?: string | null
          game_time?: string
          id?: string
          mmr_delta?: number | null
          notes?: string | null
          opponent_paragon?: Database["public"]["Enums"]["paragon"]
          opponent_rank?: Database["public"]["Enums"]["player_rank"] | null
          opponent_username?: string | null
          paragon?: Database["public"]["Enums"]["paragon"]
          player_one?: boolean
          prime_estimate?: number | null
          result?: Database["public"]["Enums"]["game_result"]
          season?: number
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "games_deck_id_fkey"
            columns: ["deck_id"]
            isOneToOne: false
            referencedRelation: "decks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "games_season_fkey"
            columns: ["season"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      seasons: {
        Row: {
          id: number
          name: string
          parallel: Database["public"]["Enums"]["parallel"]
          season_end: string
          season_start: string
          title: string
        }
        Insert: {
          id?: number
          name: string
          parallel: Database["public"]["Enums"]["parallel"]
          season_end: string
          season_start: string
          title: string
        }
        Update: {
          id?: number
          name?: string
          parallel?: Database["public"]["Enums"]["parallel"]
          season_end?: string
          season_start?: string
          title?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      calculate_opponent_paragon_percentages: {
        Args: Record<PropertyKey, never>
        Returns: {
          opponent_paragon: Database["public"]["Enums"]["paragon"]
          percentage: number
        }[]
      }
      calculate_paragon_match_count: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          count: number
        }[]
      }
      calculate_paragon_percentages: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          percentage: number
        }[]
      }
      calculate_paragon_win_count: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          count: number
        }[]
      }
      calculate_paragon_wins_and_losses: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          total_wins: number
          total_matches: number
          win_rate: number
        }[]
      }
      get_paragon_match_count: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          total_count: number
          win_count: number
          loss_count: number
        }[]
      }
      get_paragon_percentage: {
        Args: Record<PropertyKey, never>
        Returns: {
          paragon: Database["public"]["Enums"]["paragon"]
          percentage: number
        }[]
      }
    }
    Enums: {
      bond_invitation_status:
        | "requested"
        | "accepted"
        | "invited"
        | "approved"
        | "joined"
      card_rarity:
        | "common"
        | "uncommon"
        | "rare"
        | "legendary"
        | "prime"
        | "n/a"
      card_subtype: "clone" | "convergent" | "drone" | "pirate" | "vehicle"
      card_type:
        | "paragon"
        | "unit"
        | "effect"
        | "upgrade"
        | "relic"
        | "split: unit-effect"
      expansion: "Base Set" | "Battlepass" | "Planetfall" | "Aftermath"
      game_result: "win" | "loss" | "draw" | "disconnect"
      paragon:
        | "unknown"
        | "jahn"
        | "arak"
        | "juggernautWorkshop"
        | "gaffar"
        | "nehemiah"
        | "shoshanna"
        | "aetio"
        | "gnaeusValerusAlpha"
        | "scipiusMagnusAlpha"
        | "lemieux"
        | "catherine"
        | "armouredDivisionHQ"
        | "brand"
        | "newDawn"
        | "niamh"
        | "augencore"
        | "earthen"
        | "kathari"
        | "marcolian"
        | "shroud"
      parallel:
        | "augencore"
        | "earthen"
        | "kathari"
        | "marcolian"
        | "shroud"
        | "universal"
      player_rank:
        | "unranked"
        | "bronze"
        | "silver"
        | "gold"
        | "platinum"
        | "diamond"
        | "master"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type PublicSchema = Database[Extract<keyof Database, "public">]

export type Tables<
  PublicTableNameOrOptions extends
    | keyof (PublicSchema["Tables"] & PublicSchema["Views"])
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
        Database[PublicTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? (Database[PublicTableNameOrOptions["schema"]]["Tables"] &
      Database[PublicTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : PublicTableNameOrOptions extends keyof (PublicSchema["Tables"] &
        PublicSchema["Views"])
    ? (PublicSchema["Tables"] &
        PublicSchema["Views"])[PublicTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  PublicTableNameOrOptions extends
    | keyof PublicSchema["Tables"]
    | { schema: keyof Database },
  TableName extends PublicTableNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = PublicTableNameOrOptions extends { schema: keyof Database }
  ? Database[PublicTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : PublicTableNameOrOptions extends keyof PublicSchema["Tables"]
    ? PublicSchema["Tables"][PublicTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  PublicEnumNameOrOptions extends
    | keyof PublicSchema["Enums"]
    | { schema: keyof Database },
  EnumName extends PublicEnumNameOrOptions extends { schema: keyof Database }
    ? keyof Database[PublicEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = PublicEnumNameOrOptions extends { schema: keyof Database }
  ? Database[PublicEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : PublicEnumNameOrOptions extends keyof PublicSchema["Enums"]
    ? PublicSchema["Enums"][PublicEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof PublicSchema["CompositeTypes"]
    | { schema: keyof Database },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof Database
  }
    ? keyof Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends { schema: keyof Database }
  ? Database[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof PublicSchema["CompositeTypes"]
    ? PublicSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never
