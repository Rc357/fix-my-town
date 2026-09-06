import 'package:flutter/material.dart';

/// Shown by both signup and login screens when
/// EmailConfirmationRequiredException surfaces — the account exists, it
/// just has no session yet because Supabase's "Confirm email" setting is on
/// and nobody's clicked the link. A dialog, not a SnackBar: this isn't a
/// transient error to dismiss, it's a distinct state the citizen needs to
/// actually act on (go check their inbox) before anything else works.
Future<void> showConfirmEmailDialog(BuildContext context, String email) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm your email'),
      content: Text(
        'We sent a confirmation link to $email. Tap it, then come back and '
        'sign in.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
