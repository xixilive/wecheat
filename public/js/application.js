$(function(){
  $('a[rel=test_app]').click(function(e){
    e.preventDefault();
    var $el = $(this);
    $.post($el.prop('href'), function(data){
      $el.removeClass('btn-default');
      if(data && data.echo == true){
        $el.addClass('btn-success');
      }else{
        $el.addClass('btn-danger');
      }

      setTimeout(function(){
        $el.removeClass('btn-success').removeClass('btn-danger').addClass('btn-default');
      }, 3000)
    });
  });


  $('a[rel=fake_event]').click(function(e){
    e.preventDefault();
    var $el = $(this);
    $.post($el.prop('href'))
      .success(function(data){
        $el.removeClass('btn-default').addClass(data.error ? 'btn-danger' : 'btn-success');
      })
      .error(function(){
        $el.removeClass('btn-default').addClass('btn-danger');
      })
      .complete(function(){
        setTimeout(function(){
          $el.removeClass('btn-success').removeClass('btn-danger').addClass('btn-default');
        }, 3000)
      })
  });
});