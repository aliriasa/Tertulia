window.addEventListener('load', () => {
    const connectButton = document.getElementById('connectButton');
  
    connectButton.addEventListener('click', async () => {
      // Check if Metamask is installed and connected
      if (typeof window.ethereum !== 'undefined') {
        // Request Metamask to connect
        try {
          await window.ethereum.enable();
          // Redirect to index.html when connected
          window.location.href = '../html/question.html';
        } catch (error) {
          console.error('An error occurred while connecting Metamask:', error);
        }
      } else {
        console.error('Metamask is not installed.');
      }
    });
  });
  