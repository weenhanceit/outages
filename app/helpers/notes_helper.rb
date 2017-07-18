module NotesHelper
  def css_note_id(note)
    "note-" + (note.id || "new").to_s
  end
end
