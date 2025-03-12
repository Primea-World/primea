import type { Database } from '$lib/database.types';
import type { SupabaseClient, User } from '@supabase/supabase-js';
import type { UplinkDetailsParameters } from './routes/PageCardDetails.svelte';
import type { ProfileDetailsParameters } from './routes/profile/PageCardDetails.svelte';

// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		interface Locals {
			supabase: SupabaseClient<Database>;
			user: User | null;
		}
		interface PageData {
			cardDetails: Snippet;
			cardPanel: Snippet;
			uplinkData?: UplinkDetailsParameters;
			uplinkPanel?: UplinkPanelParameters;
			profileData?: ProfileDetailsParameters;
		}
		interface PageState {
			showModal: boolean;
		}
		// interface Platform {
		// 	env?: {
		// 		PRIMEA_NAMESPACE: KVNamespace;
		// 		PRIMEA_DURABLE_OBJECT_NAMESPACE: DurableObjectNamespace;
		// 	};
		// }
	}
}

export { };
