/// FR-17.1 — collapsed from the four originally requested types
/// (thumbsup/like/agree/disagree) to two: thumbsup/like/agree all describe
/// the same underlying intent (affirming the report), so modeling them
/// separately would just fragment one signal.
enum ReactionKind { support, dispute }
