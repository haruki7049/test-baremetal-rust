use crate::{graphics::GraphicsError, uefi::UefiError};

pub type Result<T> = core::result::Result<T, Error>;

#[derive(Debug, thiserror::Error)]
pub enum Error {
    #[error("Graphics error")]
    Graphics(#[from] GraphicsError),

    #[error("Uefi error")]
    Uefi(#[from] UefiError),
}
