export const generateFeedback = (guess, secretNumber) => {
    let correctPosition = 0;
    let misplaced = 0;
  
    guess.split("").forEach((digit, index) => {
      if (secretNumber[index] === digit) {
        correctPosition++;
      } else if (secretNumber.includes(digit)) {
        misplaced++;
      }
    });
  
    return { correctPosition, misplaced };
  };
  