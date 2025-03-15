export const GET = async ({ locals }) => {
  const { data: { session } } = await locals.supabase.auth.getSession();

  if (session?.access_token) {
    locals.supabase.auth.admin.signOut(session?.access_token);
  }

  return new Response(null, {
    status: 302,
    headers: {
      location: "/",
    },
  });
}