using TypeSpec.Http;

@format("UUIDv4, e.g.: \"e3bae040-7682-4457-aef8-20a419aed0bd\".")
scalar uuid extends string;

@doc("POSIX-compatible exit code: 0 for success and any number from 1 to 255 for anything else.")
scalar exitCode extends uint8;

@doc("E.g.: \"2020-01-17T00:44:37\".")
scalar timestamp extends string;

@error
model Error {
    error: boolean = true;
    message: string;
}

@error
model GenericError<Status> is Response<Status> {
    error: boolean = true;
    message: string;
}

@error
model SuccessError<Status> is Response<Status> {
    success: boolean = false;
    error: string;
}

model Success {
    success: boolean = true;
}

alias SuccessResponse = Success | SuccessError<404>;
