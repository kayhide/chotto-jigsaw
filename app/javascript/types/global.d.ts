declare global {
  interface Window {
    $: JQueryStatic;
    _: _.LodashStatic;
  }
}

declare const _;
