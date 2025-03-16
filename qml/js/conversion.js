function wattsToKilowatts(watts) {
  const kilowatts = watts / 1000;
  if (kilowatts > 1) {
    return {value: kilowatts.toFixed(2), unit: "kW"};
  } else {
    return {value: watts, unit: "W"};
  }
}
