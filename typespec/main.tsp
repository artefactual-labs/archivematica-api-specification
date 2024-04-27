import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

import "./common.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
    title: "Archivematica",
})
@route("/api")
@useAuth(ApiKeyAuth<ApiKeyLocation.header, "ApiKey">)
namespace Service {
    @route("/")
    namespace V1 {
        @route("/processing-configuration")
        namespace ProcessingConfiguration {
            @doc("Lists known processing configurations.")
            @get
            op list(): {
                @statusCode _: 200;

                @doc("List of config names.")
                @body
                body: string[];
            };

            @doc("Returns the processing configuration with the given name.")
            @route("/{name}")
            @get
            op read(
                @header accept: "*/*" | "application/xml" | "text/xml",
                @path name: string,
            ):
                | {
                      @statusCode _: 200;
                      ...ProcessingConfiguration;
                  }
                | {
                      @statusCode _: 415;
                  }
                | SuccessError<404>
                | SuccessError<500>;

            @doc("Deletes the processing configuration with the given name.")
            @route("/{name}")
            @delete
            op delete(@path name: string): SuccessResponse;

            model ProcessingConfiguration {
                @header contentType: "text/xml";
                @body body: string;
            }
        }
    }

    @route("/v2beta")
    namespace V2Beta {
        @route("/package")
        namespace Packages {
            @doc("Starts a new transfer.")
            @post
            op create(@body request: CreatePackageRequest): {
                @statusCode _: 201;
                @body response: CreatePackageResponse;
            } | GenericError<400>;

            model CreatePackageRequest {
                name: string;
                path: string;
                access_system_id?: string;
                accession?: string;
                auto_approve?: boolean;
                processing_config?: string;
                type?: TransferType;
            }

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

            model CreatePackageResponse {
                id: uuid;
            }
        }

        @route("/jobs")
        namespace Jobs {
            @doc("Return a list of jobs for the given package.")
            @route("/{id}")
            @get
            op list(
                @doc("Package ID")
                @path
                id: uuid,

                @doc("Name of the microservice the jobs belong to.")
                @query
                microservice?: string,

                @doc("UUID of the job chain link.")
                @query
                link_uuid: uuid,

                @doc("Name of the job.")
                @query
                name?: string,
            ): {
                @statusCode _: 200;
                @body response: ListJobsResponse;
            } | GenericError<400>;

            alias ListJobsResponse = Job[];

            model Job {
                status: JobStatus;
                tasks: Task[];
                uuid: uuid;
                link_uuid: uuid;
                microservice: string;
                name: string;
            }

            enum JobStatus {
                Unknown: "UNKNOWN",
                AwaitingDecision: "USER_INPUT",
                CompletedSuccessfully: "COMPLETE",
                ExecutingCommands: "PROCESSING",
                StatusFailed: "FAILED",
            }

            // Slim view of a Task.
            model Task {
                uuid: uuid;
                exit_code: exitCode;
            }
        }

        @route("/task")
        namespace Tasks {
            @doc("Return information about a task.")
            @route("/{id}")
            @get
            op read(@path id: uuid): {
                @statusCode _: 200;
                @body response: Task;
            } | GenericError<400>;

            model Task {
                uuid: uuid;
                file_name: string;
                exit_code: exitCode;
                time_created: timestamp;
                time_ended: timestamp;
                file_uuid: uuid;
                duration: DurationKnownEncoding.seconds;
                time_started: timestamp;
            }
        }

        @route("/validate")
        namespace Validate {
            @doc("""
            Validate CSVs against embedded sets of rules.

            The status value may be one of:
            - `ok`: the submitted document is valid.
            - `bad request`: the submitted document is invalid.
            """)
            @route("/{validator}")
            @post
            op create(
                @header contentType: "text/csv; charset=utf-8",
                @path validator: Validator,
                @body _: bytes,
            ): {
                @statusCode _: 200;
                @body response: ValidDocumentResponse;
            } | {
                @statusCode _: 400;
                @body response: InvalidDocumentResponse | Error;
            };

            enum Validator {
                AvalonMediaSystemCSVManifest: "avalon",
                RightsCSV: "rights",
            }

            model ValidDocumentResponse {
                valid: boolean = true;
            }

            model InvalidDocumentResponse {
                valid: boolean = false;

                @minLength(1)
                reason: string;
            }
        }
    }
}
