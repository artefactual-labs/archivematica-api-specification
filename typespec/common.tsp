using TypeSpec.Http;

@format("UUIDv4, e.g.: \"e3bae040-7682-4457-aef8-20a419aed0bd\".")
scalar uuid extends string;

@doc("POSIX-compatible exit code: 0 for success and any number from 1 to 255 for anything else.")
scalar exitCode extends uint8;

@doc("E.g.: \"2020-01-17T00:44:37\".")
scalar timestamp extends string;

enum UnitStatus {
    USER_INPUT,
    FAILED,
    REJECTED,
    COMPLETE,
    PROCESSING,
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

model ResultsResponse<T> is Response<200> {
    results: T[];
    message: string;
}

model OKResponse<Status = 200> is Response<Status> {
    message: string;
}

@error
model Error {
    error: boolean = true;
    message: string;
}

@error
model ErrorResponse<Status> is Response<Status> {
    error: boolean = true;
    message: string;
}

@error
model NonSuccessErrorResponse<Status> is Response<Status> {
    success: boolean = false;
    error: string;
}

model Success {
    success: boolean = true;
}

alias SuccessResponse = Success | NonSuccessErrorResponse<404>;

model Removed is Response<200> {
    removed: boolean = true;
}

model NotRemoved {
    @statusCode _: 409 | 500;
    removed: boolean = false;
}
