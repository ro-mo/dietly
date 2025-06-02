class UpdateExistingUsersVerificationStatus < ActiveRecord::Migration[7.1]
  def up
    # Aggiorna tutti gli utenti che hanno verification_status a nil
    User.where(verification_status: nil).update_all(verification_status: 'pending')
  end

  def down
    # Non facciamo nulla nel down perché non vogliamo riportare gli utenti a nil
  end
end
