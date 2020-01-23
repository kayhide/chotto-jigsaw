exports._lookupAuthenticityToken = () => {
  const name = document.querySelector("meta[name=csrf-param]").content;
  const value = document.querySelector("meta[name=csrf-token]").content;
  return (name && value) ? { name, value } : null;
}
