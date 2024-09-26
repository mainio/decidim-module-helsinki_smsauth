$(() => {
  let backupModal = $("#backup-confirmation-button"),
      confirmationButton = $("#backup-confirmation");

  backupModal.click(function () {
    confirmationButton.foundation("open");
  });
})
