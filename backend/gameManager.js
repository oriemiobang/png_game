export const generateFeedback = (guess, secretNumber) => {
    let position = 0;
    let number = 0;
  
    guess.split("").forEach((digit, index) => {
      if (secretNumber[index] === digit) {
        position++;
      } if (secretNumber.includes(digit)) {
        number++;
      }
    });
  
    return { position, number };
  };
  