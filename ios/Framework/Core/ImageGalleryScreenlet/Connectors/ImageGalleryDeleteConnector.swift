/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
import Foundation
import LRMobileSDK

public class ImageGalleryDeleteConnector : ServerConnector {

	private let imageEntryId: Int64


	//MARK: Initializers

	public init(imageEntryId: Int64) {
		self.imageEntryId = imageEntryId
		super.init()
	}


	//MARK: ServerConnector

	public override func validateData() -> ValidationError? {
		let error = super.validateData()

		if error == nil {
			if imageEntryId < 0 {
				return ValidationError("imagegallery-screenlet","undefined-imageentryid")
			}
		}

		return error
	}

	public override func doRun(session session: LRSession) {
		let service = LRDLAppService_v7(session: session)

		var error: NSError?

		service.deleteFileEntryWithFileEntryId(imageEntryId, error: &error)

		lastError = error
	}
	
}
