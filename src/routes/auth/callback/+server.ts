import { redirect } from '@sveltejs/kit';

export const GET = async ({ url, locals: { supabase } }) => {
  const code = url.searchParams.get('code');
  const next = url.searchParams.get('next') ?? '/';

  console.log("SSR auth");

  if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (!error) {
      throw redirect(303, `/${next.slice(1)}`);
    } else {
      console.error('Error exchanging code for session:', error.message);
      // return the user to an error page with instructions
      throw redirect(400, 'auth-code-error');
    }
  }

  // return the user to an error page with instructions
  throw redirect(400, 'auth-code-error');
};