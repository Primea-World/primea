import { SUPABASE_SECRET } from '$env/static/private'
import { PUBLIC_SUPABASE_URL } from '$env/static/public'
import type { Database } from '$lib/database.types'
import { createServerClient } from '@supabase/ssr'
import { redirect, type Handle } from '@sveltejs/kit'
import { sequence } from '@sveltejs/kit/hooks'

export const supabase: Handle = async ({ event, resolve }) => {
  event.locals.supabase = createServerClient<Database>(PUBLIC_SUPABASE_URL, SUPABASE_SECRET, {
    cookies: {
      getAll() {
        return event.cookies.getAll()
      },
      setAll(cookiesToSet) {
        /**
         * Note: You have to add the `path` variable to the
         * set and remove method due to sveltekit's cookie API
         * requiring this to be set, setting the path to an empty string
         * will replicate previous/standard behavior (https://kit.svelte.dev/docs/types#public-types-cookies)
         */
        cookiesToSet.forEach(({ name, value, options }) =>
          event.cookies.set(name, value, { ...options, path: options.path ?? '/' })
        )
      },
    },
  })

  return resolve(event, {
    filterSerializedResponseHeaders(name) {
      return name === 'content-range' || name === 'x-supabase-api-version'
    },
  })
}

const authGuard: Handle = async ({ event, resolve }) => {
  const { data: { user } } = await event.locals.supabase.auth.getUser();
  event.locals.user = user

  // if they aren't logged in, redirect to the homepage
  if (!user && event.url.pathname !== "/" && !event.url.pathname.startsWith("/twitch") && !event.url.pathname.startsWith("/priming") && !event.url.pathname.startsWith("/auth/signup") && !event.url.pathname.startsWith("/auth/login")) {
    redirect(303, '/')
  }

  return resolve(event)
}

export const handle: Handle = sequence(supabase, authGuard)
