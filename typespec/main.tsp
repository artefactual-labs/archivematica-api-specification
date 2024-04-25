import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
    title: "Archivematica",
})
@route("/api")
@useAuth(ApiKeyAuth<ApiKeyLocation.header, "ApiKey">)
namespace Service {
    @route("/v2beta")
    namespace V2 {
        @route("/package")
        namespace Packages {
            @doc("Starts a new transfer.")
            @post
            op create(@body request: CreatePackageRequest): {
                @statusCode statusCode: 201;
                @body response: CreatePackageResponse;
            } | {
                @statusCode statusCode: 400;
                @body response: Error;
            };
        }
    }
}

@format("UUIDv4, e.g.: \"e3bae040-7682-4457-aef8-20a419aed0bd\".")
scalar uuid extends string;

enum TransferType {
    Standard: "standard",
    ZipFile: "zipfile",
    UnzippedBag: "unzipped bag",
    ZippedBag: "zipped bag",
    DSpace: "dspace",
    Maildir: "maildir",
    TRIM: "TRIM",
    Dataverse: "dataverse",
}

model CreatePackageRequest {
    access_system_id?: string;
    accession?: string;
    auto_approve?: boolean;
    name?: string;
    path?: string;
    processing_config?: string;
    type?: TransferType;
}

model CreatePackageResponse {
    id: uuid;
}

@error
model Error {
    error: boolean = true;
    message: string;
}
