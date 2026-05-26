import { buildSearchAdvancedEnvelope, buildSearchAdvancedRequestXml } from "../soap.ts";

Deno.test("buildSearchAdvancedRequestXml includes expected tags", () => {
  const xml = buildSearchAdvancedRequestXml({ searchWords: "rorstrand mon amie" });
  if (!xml.includes("<SearchWords>")) throw new Error("missing SearchWords");
  if (!xml.includes("<ItemStatus>Ended</ItemStatus>")) {
    throw new Error("default ItemStatus should be Ended");
  }
});

Deno.test("buildSearchAdvancedEnvelope includes method", () => {
  const requestXml = buildSearchAdvancedRequestXml({ searchWords: "glass" });
  const env = buildSearchAdvancedEnvelope({
    appId: 1,
    appKey: "k",
    sandbox: 0,
    maxResultAge: 0,
    requestXml,
  });
  if (!env.includes("<SearchAdvanced")) {
    throw new Error("missing method");
  }
});
