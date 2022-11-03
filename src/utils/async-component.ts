export const asyncComponent = <T, R>(
  fn: (arg: T) => Promise<R>
): ((arg: T) => R) => {
  return fn as (arg: T) => R;
};
