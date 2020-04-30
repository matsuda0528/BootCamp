require 'get_json'

module QuizAPI
  def get
    url = "https://opentdb.com/api.php?amount=1&category=18"
    @json = get_json(url)
    answers = [@json['results'][0]['correct_answer']] + @json['results'][0]['incorrect_answers']
    text = <<~EOS
      Question : 
      #{@json['results'][0]['question']}
   
      Choise:
      #{answers.sort}

    EOS
    return text 
  end

  def answer(ans)
    if ans == @json['results'][0]['correct_answer']
      text = <<~EOS
      Is the correct answer.
      EOS
    else
      text = <<~EOS
      Incorrect.
      correct answer is #{@json['results'][0]['correct_answer']}.
      EOS
      return text
    end
  end

  module_function :answer
  module_function :get
end
