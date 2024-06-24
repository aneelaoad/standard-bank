const checkCookie = function(name, value) {
  const cookie = getCookie(name);
  if(!cookie) return false;
  return (cookieValue.indexOf(value.toString()) == 0);
}

const getCookie = function(name) {
  const decodedCookies = decodeURIComponent(document.cookie);
  const cookiesArray = decodedCookies.split(';');
  let cookieValue = "";
  if(cookiesArray){
    for (let i = 0; i < cookiesArray.length; i++) {
      let c = cookiesArray[i].trim();
      // not the right cookie, go to next
      if (c.indexOf(name) != 0) continue;
      // get the cookie value
      cookieValue = c.substring(name.length + 1, c.length);
      // exit the loop as we found the cookie
      break;
    }
  }
  return cookieValue;
}

  // should take name, value and expiry date
const putCookie = function(name, value) {
  const d = new Date();
  // set 24hr cookie
  d.setTime(d.getTime() + (15*60*1000));
  let expires = "expires="+ d.toUTCString();
  document.cookie = `${name}=${value.toString()};${expires};path=/;Secure;httpOnly; SameSite=Strict`;
}

const createCookie = function(name, value, days) {
  var expires;

  if (days) {
    const date = new Date();
    date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
    expires = "; expires=" + date.toGMTString();
  } else {
    expires = "";
  }

  document.cookie = name + "=" + escape(value) + expires + "; path=/";
}

const deleteCookie = function(name) {
  document.cookie = `${name}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
}

export { checkCookie, getCookie, putCookie, createCookie, deleteCookie }