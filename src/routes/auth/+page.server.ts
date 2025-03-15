import { fail, redirect } from '@sveltejs/kit'

import type { Actions } from './$types'

export const actions: Actions = {
  signup: async ({ request, locals: { supabase } }) => {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const password = formData.get('password') as string

    console.log("sign up", email, password)

    const { error: err } = await supabase.auth.signUp({ email, password })
    if (err) {
      console.error(err)
      return fail(400, { message: err.message })
    } else {
      return {
        signup: true,
      }
    }
  },
  login: async ({ request, locals: { supabase } }) => {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const password = formData.get('password') as string

    const { error: err } = await supabase.auth.signInWithPassword({ email, password })
    if (err) {
      console.error(err)
      return fail(400, { message: err.message })
    } else {
      return redirect(303, "/");
    }
  },
}