$(function(){
  function notify(type, title, text){
    new PNotify({title: title, text: text, type: type, icon: false, text_escape: true});
  }

  function reset_button(btn){
    btn.removeClass('btn-success').removeClass('btn-danger').addClass('btn-default');
  }

  function fetch_messages(){
    $.get('/last_message', function(data){
      if(data){
        notify('info', 'New message received', data.response);
      }
    }).complete(function(){ 
      setTimeout(fetch_messages, 3000);
    });
  };
  fetch_messages();

  $(document).ajaxError(function(e, xhr, config, err){
    notify('error', 'Error raised for request', err.toString());
  });


  $('a[rel=test_app]').click(function(e){
    e.preventDefault();
    var $el = $(this);
    $.post($el.prop('href'))
      .success(function(data){
        notify(data.error ? null : 'success', 'Response for testing', data.response)
      })
      .complete(function(){
        setTimeout(reset_button($el), 3000);
      });
  });


  $('a[rel=event]').click(function(e){
    e.preventDefault();
    var $el = $(this);
    $.post($el.prop('href'))
      .success(function(data){
        $el.removeClass('btn-default').addClass(data.error ? 'btn-danger' : 'btn-success');
        notify(data.error ? null : 'success', 'Response for ' + $el.text(), data.response)
      })
      .complete(function(){
        setTimeout(reset_button($el), 3000);
      })
  });

  $('form[rel=message_form]').on('submit', function(){
    var f = $(this), btn = $(':submit', f), type = $(':hidden[name="type"]', f).val();
    btn.prop('disabled', true);
    $.post(f.prop('action'), f.serialize())
      .success(function(data){
        notify(data.error ? null : 'success', 'Response for ' + type, data.response)
      })
      .complete(function(){
        btn.prop('disabled', false);
      })
    return false;
  });
});